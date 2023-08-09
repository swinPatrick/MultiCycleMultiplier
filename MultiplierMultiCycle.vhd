library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity MultiplierMultiCycle is
    Port ( Clock    : in  std_logic;
           Reset    : in  std_logic;
           A        : in  std_logic_vector(15 downto 0);
           B        : in  std_logic_vector(15 downto 0);
           Q        : out std_logic_vector(31 downto 0);
           Start    : in  std_logic;
           Complete : out std_logic);
end MultiplierMultiCycle;

architecture Behavioral of MultiplierMultiCycle is

type theStates is (IdleState, Stage1, Stage2, Stage3, Stage4); 
signal state : theStates;
-- variable signal for the result of the 8 bit multiplier
signal Product : std_logic_vector(15 downto 0);

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
         case state is
            when IdleState =>
               if (start = '1') then
                  state    <= Stage1;
                  Complete <= '0';
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
               Complete <= '1';

         end case;
      end if;
 
   end process StateMachine;

   --
   -- Asynchronous elements of the data path
   -- 
   Comb: -- combinational paths
   process( state, A, B )
   begin
      case state is
         null;
      case Stage1 =>
         Product <= A(7 downto 0) * B(7 downto 0);
      case Stage2 =>
         Product <= A(7 downto 0) * B(15 downto 8);
      case Stage3 =>
         Product <= A(15 downto 8) * B(7 downto 0);
      case Stage4 =>
         Product <= A(15 downto 8) * B(15 downto 8);
      end case;
   end process Comb;


   --
   -- Synchronous elements of the data path
   -- builds output and flip flops/registers
   Synch: -- synchronous elements
   process (reset, clock)
      variable LHS, RHS : std_logic_vector(7 downto 0);
      variable Result : std_logic_vector(31 downto 0);

   begin
      if (reset = '1') then
         Q <= (others => '0');
      elsif (clock'event and (clock = '1')) then
         case state is
            when IdleState =>
               null;
            -- Multiply seccond byte of A and B
            when Stage1 =>
               -- set first half of Result is 0, seccond half is Multipe
               Result := (others => '0');
               Result(15 downto 0) := Product;

            -- Multiply seccond byte of A with first byte of B
            when Stage2 =>
               -- add existing value of Q(15 downto 8) with Multiple. Overflow is not possible
               Result(23 downto 8) := Result(23 downto 8) + Product;

            -- Multiply first byte of A with second byte of B
            when Stage3 =>
               -- add existing value of Q(15 downto 8) with Multiple. Overflow is possible
               Result(24 downto 8) :=Result(24 downto 8) + ('0' & Product);
         
            -- Multiply first byte of A and B
            when Stage4 =>
               -- add existing value of Q(31 downto 16) with Multiple. Overflow is not possible
               Result(31 downto 16) := Result(31 downto 16) + Product;
               
               Q <= Result;
         end case;
      end if;
   end process Synch;

end architecture Behavioral;
