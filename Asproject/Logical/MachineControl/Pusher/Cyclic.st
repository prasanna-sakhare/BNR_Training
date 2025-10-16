
PROGRAM _CYCLIC
	(* Insert code here *)
	io.pusher.aoActualPosition := 100*LREAL_TO_REAL(axisHandler.Position);
	axisHandler.MpLink := ADR(gAxis_1);
	axisHandler.Parameters :=  ADR(axisParameters);
	axisHandler.Enable := TRUE;
	
	
	// commands from PIPER to cyclic
	IF machineStop THEN
		axisHandler.Home:= TRUE;
		io.pusher.state := ST_BOOT;
	END_IF 
	
	PiperInterface;
	
	// If mode 4 is selected run pusher logic
	IF mode = 4 THEN	 
		CASE io.pusher.state OF
			ST_BOOT:
				// Do nothing
				
				IF machineStart THEN
					io.pusher.state := ST_INIT;
				END_IF	
			ST_INIT:
				machineStart := FALSE;
				
				IF axisHandler.Active AND NOT axisHandler.PowerOn THEN
					axisHandler.Power := TRUE;
				ELSIF axisHandler.PowerOn AND NOT axisHandler.Home THEN
					axisHandler.Home:= TRUE;
				ELSIF axisHandler.IsHomed THEN
					io.pusher.state := ST_WAIT;
				END_IF
			
			ST_WAIT:
				axisHandler.Home:= FALSE;
				IF io.conveyor[2].diPhotoeye1 AND io.conveyor[2].doRunForward THEN
					boxLengthTimer.IN := TRUE;
					IF boxLengthTimer.ET > T#600ms THEN
						io.pusher.state := ST_PUSH;
					END_IF
				ELSE 
					boxLengthTimer.IN := FALSE;
				END_IF
			     
				
			ST_PUSH :
				axisParameters.Position := 5.0;
				axisParameters.Velocity := 5.0;
				axisParameters.Acceleration := 25.0;
				axisParameters.Deceleration := 25.0;
				axisHandler.MoveAbsolute := TRUE;
				io.pusher.extendedTimer.IN := TRUE;
				boxLengthTimer.IN := FALSE;
			
				IF axisHandler.Position = axisParameters.Position OR io.pusher.extendedTimer.Q THEN
					axisHandler.MoveAbsolute := FALSE;
					io.pusher.extendedTimer.IN := FALSE;
					io.pusher.state := ST_PULL;
				END_IF
	
			ST_PULL:
			
				axisHandler.Home:= TRUE;	
				IF axisHandler.IsHomed THEN
					axisHandler.Home:= TRUE;
					io.pusher.state := ST_WAIT;
				END_IF
		END_CASE		
	END_IF
	
	
	
	axisHandler();
	io.pusher.extendedTimer(PT := T#3s);
	boxLengthTimer(PT := T#1S);
END_PROGRAM
