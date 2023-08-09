library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity Multiplier1Cycle is
    Port ( Clock    : in  std_logic;
           Reset    : in  std_logic;
           A        : in  std_logic_vector(15 downto 0);
           B        : in  std_logic_vector(15 downto 0);
           Q        : out std_logic_vector(31 downto 0);
           Start    : in  std_logic;
           Complete : out std_logic);
end Multiplier1Cycle;

architecture Behavioral of Multiplier1Cycle is

type theStates is (IdleState, Done); 
signal state : theStates;

begin

   --
   -- Control state machine
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
                  state    <= Done;
                  Complete <= '0';
               else
                  state <= IdleState;
               end if;
            when Done =>
               state    <= IdleState;
               Complete <= '1';
         end case;
      end if;
 
   end process StateMachine;

   --
   -- Asynchronous elements of the data path
   --
--   Comb: -- combinational paths
--   process( state, A, B )
--   begin
--      case state is
--         when IdleState =>
--            --
--         when Done =>
--            --
--      end case;
--   end process Comb;
--

   --
   -- Synchronous elements of the data path
   --
   Synch: -- synchronous elements
   process (reset, clock)
   begin
      if (reset = '1') then
         Q        <= (others => '0');
      elsif (clock'event and (clock = '1')) then
         case state is
            when IdleState =>
               null;
            when Done =>
               Q <= std_logic_vector(unsigned(A) * unsigned(B));
               -- alternative ways to do the multiplication
               -- Q <= std_logic_vector(resize(unsigned(A), 32) * resize(unsigned(B), 32));
               -- Q <= std_logic_vector(unsigned(A) * unsigned(B) mod 2**32);
         end case;
      end if;
   end process Synch;

end architecture Behavioral;
