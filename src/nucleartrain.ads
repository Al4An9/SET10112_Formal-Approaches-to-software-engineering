with Ada.Text_IO; use Ada.Text_IO;

package nucleartrain with SPARK_Mode
is

   type ReactorControlRod is range 1..5;
   type ReactorWaterSupply is range 0..20;
   type ReactorElectricityGenerated is range 0..99;
   type ReactorTemperature is range 0..299;
   type ReactorOverheated is (No, Yes);
   type ReactorState is (Online, Offline);
   type PassengersCarriages is range 0..5;


   TrainMaximumSpeed : constant := 100;
   ReactorMaximumTemperature: constant:=200;

   type ReactorSpecs is record
      rods : ReactorControlRod;
      water : ReactorWaterSupply;
      temperature : ReactorTemperature;
      heat: ReactorOverheated;
      state :  ReactorState;
   end record;

   type TrainSpecs is record
      engineReactor : ReactorSpecs;
      electricity: ReactorElectricityGenerated;
      carriages : PassengersCarriages;
      travelSpeed : Integer;
      maxTravelSpeed : Integer;
   end record;

   reactor : ReactorSpecs := (rods => ReactorControlRod'Last,
                              water => ReactorWaterSupply'Last,
                              temperature => ReactorTemperature'First,
                              heat => No,
                              state => Online);

   train : TrainSpecs := (engineReactor => reactor,
                          carriages => PassengersCarriages'First,
                          electricity =>ReactorElectricityGenerated'First,
                          travelSpeed => 0,
                          maxTravelSpeed => 0);

   -- Reactor must have at least one cortrol rod inserted at all times
   function Invariant return Boolean is
     (train.engineReactor.rods >= ReactorControlRod'First);

   procedure initiateReactor with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.engineReactor.state = Offline,
     Post => train.engineReactor.state = Online;

   procedure maintenanceReactor with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.engineReactor.state = Online
     and then train.travelSpeed = 0,
     Post => train.engineReactor.state = Offline;

   procedure insertControlRod with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => Invariant
     and then train.engineReactor.rods < ReactorControlRod'Last,
     Post => train.engineReactor.rods = train.engineReactor.rods'Old + 1;

   procedure removeControlRod with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.engineReactor.rods > ReactorControlRod'First,
     Post => train.engineReactor.rods = train.engineReactor.rods'Old - 1;

   procedure addOneCarriage with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.travelSpeed = 0
     and then train.carriages < PassengersCarriages'Last,
     Post => train.carriages = train.carriages'Old + 1;

   procedure removeOneCarriage with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.carriages > PassengersCarriages'First,
     Post => train.carriages = train.carriages'Old - 1;

   procedure reactorOnline with
     Global =>(In_Out => train),
     Pre => train.engineReactor.temperature < ReactorTemperature'Last - 5
     and then train.travelSpeed < TrainMaximumSpeed
     and then train.travelSpeed < train.maxTravelSpeed
     and then train.engineReactor.state = Online
     and then Invariant,
     Post => train.engineReactor.temperature > train.engineReactor.temperature'Old
     and then train.electricity /= 0;

   procedure startTrain with
     Global => (In_Out => train),
     Pre => train.travelSpeed = 0
     and then Invariant
     and then train.engineReactor.state = Online,
     Post => train.travelSpeed > 0;

   procedure stopTrain with
     Global => (In_Out => (train, Ada.Text_IO.File_System )),
     Pre => train.travelSpeed >= 0 or train.travelSpeed <= 0,
     Post => train.travelSpeed = 0
     and then train.electricity = 0
     and then train.engineReactor.temperature = ReactorTemperature'First
     and then train.maxTravelSpeed = 0;

   procedure setTrainMaximumSpeed with
     Global => (In_Out =>(train, Ada.Text_IO.File_System)),
     Pre => train.travelSpeed >= 0,
     Post => train.travelSpeed >= 0;

   procedure trainAcceleration with
     Global => (In_Out => (train, Ada.Text_IO.File_System)),
     Pre => Invariant
     and then train.engineReactor.state = Online
     and then train.travelSpeed < TrainMaximumSpeed
     and then train.travelSpeed < train.maxTravelSpeed,
     Post => train.travelSpeed = train.travelSpeed'Old + 1;

   procedure warnReactorOverheat with
     Global => (In_Out => (train, Ada.Text_IO.File_System)),
     Pre => Invariant
     and then train.engineReactor.temperature >= 200
     and then train.engineReactor.state = Online
     and then train.engineReactor.heat = No,
     Post => train.engineReactor.heat = Yes;

   procedure waterCooldownReactor with
     Global => (In_Out => (train, Ada.Text_IO.File_System)),
     Pre => Invariant
     and then train.travelSpeed > 0
     and then train.engineReactor.temperature >= ReactorMaximumTemperature
     and then train.engineReactor.water >= 2,
     Post => train.engineReactor.temperature = train.engineReactor.temperature'Old - 50
     and then train.engineReactor.water = train.engineReactor.water'Old - 2;

   procedure refillWaterSupply with
     Global => (In_Out => (train, Ada.Text_IO.File_System)),
     Pre => train.travelSpeed = 0
     and then train.engineReactor.water < ReactorWaterSupply'Last,
     Post => train.engineReactor.water = ReactorWaterSupply'Last;

end NuclearTrain;
