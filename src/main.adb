with nucleartrain; use nucleartrain;
with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   inp : String (1..1);
   last : Integer := 80;

   procedure ShowTrainCurrentAttributes is
   begin
      Put_Line("____________________________________");
      Put_Line(" TRAIN");
      Put_Line(" carriages attached:    "& train.carriages'Image);
      Put_Line(" electricity produced:  "& train.electricity'Image);
      Put_Line(" travelling speed:      "& train.travelSpeed'Image);
      Put_Line(" max travelling speed:  "& train.maxTravelSpeed'Image);
      Put_Line("____________________________________");
      Put_Line(" REACTOR");
      Put_Line(" control rods inserted: "& train.engineReactor.rods'Image);
      Put_Line(" water supply:          "& train.engineReactor.water'Image);
      Put_Line(" temperature:           "& train.engineReactor.temperature'Image);
      Put_Line(" overheated:             "& train.engineReactor.heat'Image);
      Put_Line(" reactor state:          "& train.engineReactor.state'Image);
      Put_Line("_____________________________________");
   end ShowTrainCurrentAttributes;

   procedure ShowInputMenu is
   begin
      Put_Line("____________________________________________");
      Put_Line("Input Menu:");
      Put_Line("1-> Start/Stop Train");
      Put_Line("2-> Reactor State");
      Put_Line("3-> Insert/Remove control rods");
      Put_Line("4-> Insert/Remove Carriages");
      Put_Line("5-> Refill water supply");
      Put_Line("6-> Show Train & Reactor current Attributes");
      Put_Line("7-> Show Input Menu");
      Put_Line("8-> Stop & Exit");
      Put_Line("____________________________________________");
   end ShowInputMenu;

   task TrainControllerUI;
   task StartTheShow;
   task HeatAlarm;

   task body TrainControllerUI is
   begin
      ShowTrainCurrentAttributes;
      ShowInputMenu;

         loop
         Put_Line("");
         Put("Insert input 1-8 and press enter to proceed(input 7 to see input menu):");
         Get(inp);
         if (inp = "1") then
            if train.travelSpeed > 0 then stopTrain;
            elsif (train.engineReactor.state = Online) then
               startTrain;
            else Put_Line("Please set the Reactor state to Online to start the train.");
            end if;
         elsif (inp = "2") then
            if (train.engineReactor.state = Online and then train.travelSpeed = 0) then
               maintenanceReactor;
            else initiateReactor;
            end if;
         elsif (inp = "3") then
            Put_Line("i - insert one Control Rod");
            Put_Line("r - remove one Control Rod");
            Get(inp);
            if(inp = "i") then insertControlRod;
            elsif (inp = "r") then removeControlRod;
            end if;
         elsif (inp = "4") then
            Put_Line("i - insert one Carriage");
            Put_Line("r - remove one Carriage");
            Get(inp);
            if(inp = "i") then
               if (train.travelSpeed = 0) then addOneCarriage;
               else Put_Line("Please stop the train in order to attach Carriages.");
               end if;
            elsif (inp = "r") then
               if (train.carriages > PassengersCarriages'First) then
                  removeOneCarriage;
               else Put_Line("There are no carriages attached.");
               end if;
            end if;
         elsif (inp = "5") then
            Put_Line("r - refill water supply");
            Get(inp);
            if(inp = "r") then
               if (train.travelSpeed = 0) then refillWaterSupply;
               else Put_Line("Please stop the train in order to refill the water supply.");
               end if;
            end if;
         elsif (inp = "6") then ShowTrainCurrentAttributes;
         elsif (inp = "7") then ShowInputMenu;
         elsif (inp = "8") then abort StartTheShow; abort HeatAlarm; exit;
         else abort StartTheShow; abort HeatAlarm; exit;
         end if;
         end loop;
   end TrainControllerUI;

   task body StartTheShow is
   begin
      loop
         if (train.travelSpeed > 0) then
            reactorOnline;
            setTrainMaximumSpeed;
            trainAcceleration;
            Put_Line("");
            Put_Line("Maximum travelling speed:"& train.maxTravelSpeed'Image
                     & " /// Travelling speed:"& train.travelSpeed'Image
                     & " /// Reactor temperature:"& train.engineReactor.temperature'Image
                     & " /// Reactor Electricity produced: " & train.electricity'Image);
         end if;
         delay 0.5;
      end loop;
   end StartTheShow;

   task body HeatAlarm is
   begin
      loop
         if (train.travelSpeed > 0 and then train.engineReactor.temperature >= 200) then
            warnReactorOverheat;
            waterCooldownReactor;
         end if;
         delay 0.5;
      end loop;
   end HeatAlarm;

begin
   null;
end Main;
