const unsigned char instructions[128] = {
  //DO NOT CHANGE ANYTHING BEFORE THIS POINT.
  //Replace those with your own instructions!
/*
  0b01010101,
  0b11001100,
  0b11110000,
  0b00001111,
  0b10101010,
  0b11111111,
  0b11111111,
  0b11010111,
*/
 0b01110010,   //MVN R2, #0
 0b01010101,   //MOV R1, #1
 0b10001000,   //STRB R0, [R2, #0]
 0b00000001,   //ADD R0, R0, R1
 0b01011110,   //MOV R3, #2

  //DO NOT CHANGE ANYTHING PAST THIS POINT.
};

#include <bitset>
#include <iomanip>
#include <iostream>

using namespace std;

unsigned char registers[4] = { 0x00, 0x00, 0x00, 0x00 };
unsigned char data_written_to_sound_card[256] = {};
unsigned char bytes_written_to_sound_card = 0;

void interpret_one_instruction() {
  cout << "Fetching instruction from PC, at location 0x" << setw(2) << setfill('0') << hex
       << (int) registers[3] << endl;
  unsigned char instruction;
  if (registers[3] <= 127) {
    instruction = instructions[registers[3]];
  } else {
    cout << "Executing from unmapped memory, instruction data will be 0." << endl;
    instruction = 0;
  }
  
  registers[3] = registers[3] + 1;
  
  bitset<8> bits = bitset<8>(instruction);
  cout << "  Got instruction: 0x" << setfill('0') << setw(2) << hex << (int) instruction << " / 0b" << bits << endl;
  
  bool is_memory_operation = bits[7] != 0;
  if (is_memory_operation) {
    bool is_load = bits[6] != 0;
    
    int memory_offset = bits[5]*2 + bits[4];
    int memory_pointer_register = bits[3]*2 + bits[2];
    int register_file_register = bits[1]*2 + bits[0];
    
    if (is_load) {
      cout << "    Instruction is a LDRB" << endl;
      cout << "    LDRB R" << register_file_register << ", [R" << memory_pointer_register << ", #" << memory_offset << "]" << endl;
      int memory_location = registers[memory_pointer_register] + memory_offset;
      if (memory_location < 128) {
        cout << "      Reading from ROM at location: 0x" << hex << setw(2) << setfill('0') << memory_location << endl;
        registers[register_file_register] = instructions[memory_location];
      } else if (memory_location == 255) {
        cout << "      Attempt to read from the sound card" << endl;
        registers[register_file_register] = 0;
      } else {
        cout << "      Attempt to read from an unknown peripheral" << endl;
        registers[register_file_register] = 0;
      }
      
      
    } else {

      cout << "    Instruction is a STRB" << endl;
      cout << "    STRB R" << register_file_register << ", [R" << memory_pointer_register << ", #" << memory_offset << "]" << endl;
      int memory_location = registers[memory_pointer_register] + memory_offset;
      int data_item = registers[register_file_register];
      if (memory_location < 128) {
        cout << "ERROR! Attempted to write to ROM!" << endl;
        abort();
      } else {
        if (memory_location == 255) {
          cout << "      Write to the sound card peripheral, with value: 0x" << hex << data_item << endl;

          data_written_to_sound_card[bytes_written_to_sound_card] = data_item;
          bytes_written_to_sound_card = bytes_written_to_sound_card + 1;
          
        } else {
          cout << "      Write to an unknown peripheral at address 0x" << hex << setw(2) << setfill('0') << memory_location << endl;
          abort();
        }
      }
    }        
  } else {
    bool is_move = bits[6] == 1;
    
    if (is_move) {
      bool is_negating = bits[5] == 1;
      
      if (is_negating) {
        cout << "    Instruction is a MVN" << endl;
        
        int target_register = bits[1]*2 + bits[0];
        int immediate_or_reg = bits[3]*2 + bits[2];
        bool use_immediate = bits[4];
        unsigned char move_source;
          
          if (use_immediate) {
            
            move_source = immediate_or_reg;
            cout << "    MVN R" << target_register << ", #" << (int)move_source << endl;
            
          } else {
            move_source = registers[immediate_or_reg];
            cout << "    MVN R" << target_register << ", R" << immediate_or_reg << endl;          
          }
          registers[target_register] = move_source ^ 0xff;
          
      } else {
        cout << "    Instruction is a MOV" << endl;
        
        int target_register = bits[3]*2 + bits[2];
        int immediate_or_reg = bits[1]*2 + bits[0];
        bool use_immediate = bits[4];
        unsigned char move_source;
        
        if (use_immediate) {
          move_source = immediate_or_reg;
          cout << "    MOV R" << target_register << ", #" << (int)move_source << endl;
        } else {
          move_source = registers[immediate_or_reg];
          cout << "    MOV R" << target_register << ", R" << immediate_or_reg << endl;
        }
        registers[target_register] = move_source;
      }
      
    } else {
      cout << "    Instruction is an ADD" << endl;
      int target_register;
      int first_source;
      int second_source;

      target_register = bits[5] * 2 + bits[4];
      first_source    = bits[3] * 2 + bits[2];
      second_source   = bits[1] * 2 + bits[0];

      cout << "    ADD R" << target_register << ", R" << first_source << ", R" << second_source << endl;

      unsigned char add_result = registers[first_source] + registers[second_source];
      registers[target_register] = add_result;
      
    }
  }

  cout << "Register dump: " << endl;
  cout << "   R0: 0x" << setfill('0') << setw(2) << hex << (int) registers[0] << " / 0b" << bitset<8>(registers[0]) << " / " << dec << setw(3) << setfill(' ')  << (int) registers[0] <<  endl;
  cout << "   R1: 0x" << setfill('0') << setw(2) << hex << (int) registers[1] << " / 0b" << bitset<8>(registers[1]) << " / " << dec << setw(3) << setfill(' ') << (int) registers[1] <<  endl;
  cout << "   R2: 0x" << setfill('0') << setw(2) << hex << (int) registers[2] << " / 0b" << bitset<8>(registers[2]) << " / " << dec << setw(3) << setfill(' ') << (int) registers[2] <<  endl;
  cout << "PC/R3: 0x" << setfill('0') << setw(2) << hex << (int) registers[3] << " / 0b" << bitset<8>(registers[3]) << " / " << dec << setw(3) << setfill(' ') << (int) registers[3] <<  endl;
  cout << endl;
}


bool check_for_completion() {
  int current_cell = 0;
  while (current_cell != 256) {
    if (data_written_to_sound_card[current_cell] != current_cell) {
      return false;
    }
    current_cell = current_cell + 1;
  }
  
  return true;

}

int main() {

  bool assignment_is_complete = false;
  int instruction_limit = 10000;

  while (!assignment_is_complete && instruction_limit > 0) {
    interpret_one_instruction();
    instruction_limit = instruction_limit - 1;

    assignment_is_complete = check_for_completion();
  }

  if (assignment_is_complete) {
    cout << "Assignment complete" << endl;
  } else {
    cout << "Over instructions executed limit. :(" << endl;
  }

  return 0;
}

