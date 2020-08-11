with Ada.Text_IO; use Ada.Text_IO;

package body nucleartrain with SPARK_Mode
is

   procedure initiateReactor is
   begin
      train.engineReactor.state := Online;
        Put_Line ("Reactor state:"& train.engineReactor.state'Image);
   end initiateReactor;

   procedure maintenanceReactor is
   begin
      if (train.engineReactor.state = Online and then train.travelSpeed = 0) then
         train.engineReactor.state := Offline;
         Put_Line("Reactor state:"& train.engineReactor.state'Image);
      end if;
   end maintenanceReactor;

   procedure insertControlRod is
   begin
      if(train.engineReactor.rods < ReactorControlRod'Last) then
         train.engineReactor.rods:= train.engineReactor.rods + 1;
         Put_Line("An additional control rod has been inserted:"&train.engineReactor.rods'Image);
      elsif (train.engineReactor.rods = ReactorControlRod'Last) then
         Put_Line("Maximum number of control rods has been reached!");
      end if;
   end insertControlRod;

   procedure removeControlRod is
   begin
      if (train.engineReactor.rods > ReactorControlRod'First) then
         train.engineReactor.rods:= train.engineReactor.rods - 1;
         Put_Line("One control rod has been removed:"& train.engineReactor.rods'Image);
      elsif (train.engineReactor.rods = ReactorControlRod'First) then
         Put_Line("Minimum number of control rods has been reached!");
      end if;
   end removeControlRod;

   procedure addOneCarriage is
   begin
      if (train.travelSpeed = 0 and then train.carriages < PassengersCarriages'Last) then
         train.carriages := train.carriages + 1;
         Put_Line("An additional carriage has been attached:"& train.carriages'Image);
      elsif (train.travelSpeed = 0 and then train.carriages = PassengersCarriages'Last) then
            Put_Line("Maximum number of carriages has been reached!");
      end if;
   end addOneCarriage;

   procedure removeOneCarriage is
   begin
      if (train.carriages > PassengersCarriages'First) then
         train.carriages := train.carriages - 1;
         Put_Line("One carriage has been removed"& train.carriages'Image);
      end if;
   end removeOneCarriage;

   procedure reactorOnline is
   begin
      if (train.engineReactor.rods = 1) then
          train.electricity := ReactorElectricityGenerated'Last;
          train.engineReactor.temperature := train.engineReactor.temperature + 5;
      elsif (train.engineReactor.rods = 2) then
            train.electricity := (ReactorElectricityGenerated'Last * 80/100);
            train.engineReactor.temperature := train.engineReactor.temperature + 4;
      elsif (train.engineReactor.rods = 3) then
            train.electricity := (ReactorElectricityGenerated'Last * 60/100);
            train.engineReactor.temperature := train.engineReactor.temperature + 3;
      elsif (train.engineReactor.rods =  4) then
            train.electricity := (ReactorElectricityGenerated'Last * 40/100);
            train.engineReactor.temperature := train.engineReactor.temperature + 2;
      elsif (train.engineReactor.rods =  5) then
            train.electricity := (ReactorElectricityGenerated'Last * 20/100);
            train.engineReactor.temperature := train.engineReactor.temperature + 1;
      end if;
   end reactorOnline;

   procedure startTrain is
   begin
      if (Invariant and then train.engineReactor.state = Online) then
         train.travelSpeed := 1;
         end if;
   end startTrain;

   procedure stopTrain is
   begin
      train.travelSpeed := 0;
      train.electricity := 0;
      train.maxTravelSpeed := 0;
      train.engineReactor.temperature := ReactorTemperature'First;
      Put_Line("Train has been stopped.");
   end stopTrain;

   procedure setTrainMaximumSpeed is
   begin
      train.maxTravelSpeed := Integer(train.electricity) - (5* Integer(train.carriages));
      if(train.maxTravelSpeed <= 0) then
         Put_Line("");
         Put_Line("Reduce the number of control rods to reduce heat and increase speed.");
         stopTrain;
      end if;
   end setTrainMaximumSpeed;

   procedure trainAcceleration is
   begin
      if (train.travelSpeed < TrainMaximumSpeed
          and then train.travelSpeed < train.maxTravelSpeed
          and then train.engineReactor.state = Online) then
         train.travelSpeed := train.travelSpeed + 1;
      else
         Put_Line("Maximum speed limit has been reached.");
      end if;
   end trainAcceleration;

   procedure warnReactorOverheat is
   begin
      if (train.engineReactor.temperature >= ReactorMaximumTemperature) then
         train.engineReactor.heat := Yes;
         Put_Line("!!Reactor is now OVERHEATED. Please stop the train or use water supply!!!REACTOR OVERHEATED: " &train.engineReactor.heat'Image);
      end if;
   end warnReactorOverheat;

   procedure waterCooldownReactor is
   begin
      if (train.engineReactor.water > ReactorWaterSupply'First + 1 and then train.engineReactor.temperature >= ReactorMaximumTemperature) then
         train.engineReactor.water := train.engineReactor.water - 2;
         train.engineReactor.temperature := train.engineReactor.temperature - 50;
         Put_Line(" ");
         Put_Line("Using water supply for cooldown. Water supply remaining:"& train.engineReactor.water'Image);
      elsif (train.engineReactor.water = 0 and then train.engineReactor.temperature >= ReactorMaximumTemperature) then
         stopTrain;
         Put_Line("Insufficient water supply. Train is stopping to avoid overheating and refill water supply.");
      end if;
   end waterCooldownReactor;

   procedure refillWaterSupply is
   begin
      if (train.travelSpeed = 0) then
         train.engineReactor.water := ReactorWaterSupply'Last;
         Put_Line("Water supply has been refilled:"& train.engineReactor.water'Image);
      end if;
   end refillWaterSupply;

end NuclearTrain;
