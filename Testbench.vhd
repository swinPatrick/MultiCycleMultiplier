-- VHDL Test Bench Created from source file multiplier.vhh

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

entity testbench is
end testbench;

architecture behavior of testbench is 

-- ports of UUT
signal Clock    :  std_logic := '0';
signal A        :  std_logic_vector(15 downto 0) := (others => '0');
signal B        :  std_logic_vector(15 downto 0) := (others => '0');
signal actualQ        :  std_logic_vector(31 downto 0) := (others => '0');
signal expectedQ        :  std_logic_vector(31 downto 0) := (others => '0');
signal Start    :  std_logic := '0';
signal aComplete :  std_logic := '0';
signal eComplete :  std_logic := '0';
signal reset    :  std_logic := '0';
  
  
--  File to log results to
file logFile : TEXT;

constant clockHigh   : time := 50 ns; 
constant clockLow    : time := 50 ns; 
constant clockPeriod : time := clockHigh + clockLow; 
    
signal   simComplete : boolean := false;

begin

   --****************************************************
   -- Clock Generator
   --
   ClockGen:
   process

   begin
      while not simComplete loop
         clock <= '0';  wait for clockHigh;
         clock <= '1';  wait for clockLow;
      end loop;

      wait; -- stop process looping
   end process ClockGen;

   --****************************************************
   -- Stimulus Generator
   --
   Stimulus:
   process

   --*******************************************************
   -- Write a message to the logfile & transcript
   --
   --  message => string to write
   --
   procedure writeMsg ( message : string
                      ) is

   variable assertMsgBuffer : String(1 to 4096); -- string for assert message
   variable writeMsgBuffer : line; -- buffer for write messages

   begin
      write(writeMsgBuffer, message);
      assertMsgBuffer(writeMsgBuffer.all'range) := writeMsgBuffer.all;
      writeline(logFile, writeMsgBuffer);
      deallocate(writeMsgBuffer);
      report assertMsgBuffer severity note;
   end;

   procedure doMultiply( stimulusA : unsigned(15 downto 0);
                         stimulusB : unsigned(15 downto 0)
                         ) is

   variable assertMsgBuffer : String(1 to 4096); -- string for assert message
   variable writeMsgBuffer  : line; -- buffer for write messages
   --variable expectedQ       : std_logic_vector(31 downto 0);
   --variable actualQ         : std_logic_vector(31 downto 0);

   begin

      -- format the test message
      -- If Q == aQ, then pass, else fail.
      -- pass message: "- A = 2, B = 2, Q = 4, Expected = 4"
      -- fail message: "X A = 2, B = 2, Q = 5, Expected = 4"

      --  Fill out with your test sequence for the multiplier
      --  Apply stimulus to A,B and start

      A <= std_logic_vector(stimulusA);
      B <= std_logic_vector(stimulusB);
      Start <= '1';
      wait until rising_edge(Clock);
      Start <= '0';
      wait until rising_edge(Clock) and aComplete = '1';

      --  Wait for clock edge(you know the multiplier has commenced)
      --  Wait for a clock edge + completed
      --  Calculate the actual value from A and B and conpare to expected value
      --  Report result.
      
      -- if statement to test Q is correct
      if (expectedQ = actualQ) then
         write( writeMsgBuffer, string'("- A = "), left );
      else
         write( writeMsgBuffer, string'("X A = "), left );
      end if;
      
      write( writeMsgBuffer, to_integer(stimulusA) );
      --write( writeMsgBuffer, to_bitvector(stimulusA) );

      write( writeMsgBuffer, string'(", B = "), left );
      write( writeMsgBuffer, to_integer(stimulusB) );
      
      -- if unsigned has 1 in 32nd bit, then it is negative, so write as bitvector
      if (signed(actualQ) >= 0) then
         write( writeMsgBuffer, string'(", Calculated = "), left );
         write( writeMsgBuffer, to_integer(unsigned(actualQ)) );
         write( writeMsgBuffer, string'(", Expected = "), left );
         write( writeMsgBuffer, to_integer(unsigned(expectedQ)) );
      else
         write( writeMsgBuffer, string'(", Calculated = "), left );
         write( writeMsgBuffer, to_bitvector(actualQ) );
         write( writeMsgBuffer, string'(", Expected = "), left );
         write( writeMsgBuffer, to_bitvector(expectedQ) );
      end if;
      

      assertMsgBuffer(writeMsgBuffer.all'range) := writeMsgBuffer.all;
      writeline(logFile, writeMsgBuffer);
      deallocate(writeMsgBuffer);
      report assertMsgBuffer severity note;
   end;

   variable openStatus : file_open_status;

   begin -- Stimulus

      file_open(openStatus, logFile, "results.txt", WRITE_MODE);

      writeMsg( string'("Simulation starting.") );

      -- initial reset
      A     <= (others => '0');
      B     <= (others => '0');
      Start <= '0';

      reset <= '1';
      wait for 10 ns;
      reset <= '0';
      wait until falling_edge(Clock);
      

      -- Test cases - modify as needed.

      -- List of test cases to run, and what they're testing for (reasoning)
      -- 1. 2 * 2 = 4 | testing that multiplying by a small number works
      doMultiply( "0000000000000010", "0000000000000010" );

      -- 2. 100 * 300 = 30000 | testing that multiplying by a number with a 1 in the 8th bit works
      doMultiply( 
         (to_unsigned(100,16)),
         (to_unsigned(300,16)));

      -- 3. 4 * 18 = 72 | testing that multiplying by a number with a 1 in the 5th bit works
      doMultiply( "0000000000000100", "0000000000100010" );

      -- 4. 65535 * 65535 = 4294836225 | testing that multiplying by the max value works
      doMultiply( 
         (to_unsigned(65535,16)),
         (to_unsigned(65535,16)));

      -- 5. 65535 * 0 = 0 | testing that multiplying by 0 works
      doMultiply( 
         (to_unsigned(65535,16)),
         (to_unsigned(0,16)));

      -- 6. 65535 * 1 = 65535 | testing that multiplying by 1 works
      doMultiply( 
         (to_unsigned(65535,16)),
         (to_unsigned(1,16)));

      -- 7. 65535 * 2 = 131070 | testing that multiplying by 2 works
      doMultiply( 
         (to_unsigned(65535,16)),
         (to_unsigned(2,16)));

      wait for 20 ns;

      writeMsg( string'("Simulation completed.") );

      file_close(logFile);

      simComplete <= true; -- stop clock & simulation

      wait;

   end process Stimulus;

   uut: entity work.Multiplier1Cycle
   port map (
       reset    => reset,
       Clock    => Clock,
       A        => A,
       B        => B,
       Q        => expectedQ,
       Start    => Start,
       Complete => eComplete
       );
   
   dut: entity work.MultiplierMultiCycle
   port map (
         reset    => reset,
         Clock    => Clock,
         A        => A,
         B        => B,
         Q        => actualQ,
         Start    => Start,
         Complete => aComplete
         );

end;
