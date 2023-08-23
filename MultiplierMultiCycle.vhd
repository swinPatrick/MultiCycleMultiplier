library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity MultiplierMultiCycle is
    Port ( Clock    : in  std_logic;
           Reset    : in  std_logic;
           A        : in  unsigned(15 downto 0);
           B        : in  unsigned(15 downto 0);
           Q        : out unsigned(31 downto 0);
           Start    : in  std_logic;
           Complete : out std_logic);
end MultiplierMultiCycle;

architecture Behavioral of MultiplierMultiCycle is

type theStates is (IdleState, Stage1, Stage2, Stage3, Stage4); 
signal state : theStates;
-- variable signal for the result of the 8 bit multiplier
-- possibly use signal to avoid latches
signal Result : unsigned(31 downto 0); -- The result of the 16x16 multiplication
signal Product : unsigned(15 downto 0); -- The result of the 8x8 multiplication
signal LHS, RHS : unsigned(7 downto 0); -- The left and right hand side of the 8x8 multiplication


begin
   --
   -- Control state machine
   -- IdleState
   -- Stage1
   -- Stage2
   -- Stage3
   -- Stage4
   --
   StateMachine: -- State machine
   process (reset, clock)
   begin
      if (reset = '1') then
         state    <= IdleState;
         Complete <= '0';
      elsif rising_edge(clock) then
      
      -- Manage State Machine
         case state is
            when IdleState =>
               if (start = '1') then
                  state    <= Stage1;
               else
                  state <= IdleState;
               end if;
            when Stage1 =>
               state <= Stage2;
            when Stage2 =>
               state <= Stage3;
            when Stage3 =>
               state <= Stage4;
            when Stage4 => 
               state <= IdleState;
         end case;
         
     -- Manage Complete Signal
         case state is
            when Stage4 =>
                Complete <= '1';
            when others =>
                Complete <= '0';
         end case;
      end if;
 
   end process StateMachine;
   

   --
   -- Asynchronous elements of the data path
   -- 
   Comb: -- combinational paths
   process( state )
      -- watching for changes in stat
      -- change values of LHS and RHS depernding on the state
   begin
      case state is
      when IdleState | Stage1 | Stage2 =>
         LHS <= A(7 downto 0);
      when Stage3 | stage4=>
         LHS <= A(15 downto 8);
      end case;
      
      case state is
      when IdleState | Stage1 | Stage3 =>
         RHS <= B(7 downto 0);
      when Stage2 | Stage4 =>
         RHS <= B(15 downto 8);
      end case;
   end process Comb;


   --
   -- Synchronous elements of the data path
   -- 
   Synch: -- synchronous elements
   process (reset, clock)
   begin
      if (reset = '1') then
         Result <= (others => '0');
      elsif rising_edge(clock) then
         case state is
            when IdleState =>
                Result <= Result;
            -- Multiply seccond byte of A and B
            when Stage1 =>
               -- set first half of Result is 0, seccond half is Multipe
               Result <= (others => '0');
               Result(15 downto 0) <= Product;

            -- Multiply seccond byte of A with first byte of B. Both are 17 bit adders so same hardware can be used.
            when Stage2 =>
               -- add existing value of Q(15 downto 8) with Multiple. Overflow is not possible
               Result(24 downto 8) <= Result(24 downto 8) + Product;

            -- Multiply first byte of A with second byte of B
            when Stage3 =>
               -- add existing value of Q(15 downto 8) with Multiple. Overflow is possible
               Result(24 downto 8) <= Result(24 downto 8) + Product;
         
            -- Multiply first byte of A and B
            when Stage4 =>
               -- add existing value of Q(31 downto 16) with Multiple. Overflow is not possible
               Result(31 downto 16) <= Result(31 downto 16) + Product;
               
         end case;
      end if;
   end process Synch;

   Product <= LHS * RHS;
   Q <= Result;

end architecture Behavioral;
