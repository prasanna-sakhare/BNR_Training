
PROGRAM _CYCLIC
	(* Insert code here *)
	
//	IF diPhotoeye = FALSE THEN
//		doPusher := TRUE;
//	END_IF	
	PiperInterface;
		
	
	CASE state OF 
	
		ST_STOP:
			counter := 0;
			IF startCounting THEN
				state := ST_RUNNING;
			END_IF	
		ST_RUNNING:
			counter := counter +1;
			IF counter> 500 THEN
				CounterDone := TRUE;
				state := ST_DONE;
			END_IF	
		ST_DONE:
		 // Do nothing
		     
	END_CASE
	
	
	// Set mode for operation
	mode := 4;
	
	IF machineStart THEN
		io.conveyor[0].state := ST_IDLE;
		io.conveyor[1].state := ST_IDLE;
		io.conveyor[2].state := ST_IDLE;
		io.conveyor[3].state := ST_IDLE;
	ELSIF machineStop THEN
		io.conveyor[0].state := ST_BOOTING;
		io.conveyor[1].state := ST_BOOTING;
		io.conveyor[2].state := ST_BOOTING;
		io.conveyor[3].state := ST_BOOTING;
	END_IF	
	  
	IF machineRunning AND (spawnTimer.Q AND NOT io.conveyor[0].diPhotoeyeEntrance) AND NOT (io.conveyor[0].state = ST_SINGIN) THEN
		io.spawnCase := TRUE;
		spawnTimer.IN := FALSE;
	ELSE
		io.spawnCase := FALSE;
		spawnTimer.IN := TRUE;
	END_IF
			
	FOR i := 0 TO MAI_CONVEYORS DO 
		
		// Zone timers
		io.conveyor[i].singinTimer();
		io.conveyor[i].singoutTimer();
		io.conveyor[i].singinTimer.PT := T#6s;
		io.conveyor[i].singoutTimer.PT := T#1200ms;
				
		IF mode = 2 THEN
			IF io.conveyor[0].diPhotoeyeEntrance THEN	
				direction := TRUE;
			END_IF 			
			IF io.conveyor[3].diPhotoeyeExit THEN
				direction := FALSE;
			END_IF
		END_IF		
		
		// defining signals
		IF mode = 2 THEN	
			IF NOT direction THEN 
				io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeExit;
				io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeEntrance;
				io.conveyor[i].doRunReverse := io.conveyor[i].runMotor;
				io.conveyor[i].doRunForward := FALSE;
			ELSE
				io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeEntrance;
				io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeExit;
				io.conveyor[i].doRunForward := io.conveyor[i].runMotor;
				io.conveyor[i].doRunReverse := FALSE;
			END_IF	
		ELSE		
			io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeEntrance;	
			io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeExit;
			io.conveyor[i].doRunForward := io.conveyor[i].runMotor;
			io.conveyor[i].doRunReverse := FALSE;
		END_IF	
			
		// Ready to send signal definition for different modes
		IF mode = 2 THEN
			IF io.conveyor[i].diPhotoeye2 AND io.conveyor[i].singinHoldTimer.Q THEN
				io.conveyor[i].readyToSend := TRUE;
			ELSE 
				io.conveyor[i].readyToSend := FALSE;
			END_IF	
		ELSE
			IF io.conveyor[i].diPhotoeye2 THEN
				io.conveyor[i].readyToSend := TRUE;	
			ELSE
				io.conveyor[i].readyToSend := FALSE;
			END_IF	
		END_IF
		
		// Ready to Receieve signal definition for different modes
		IF NOT io.conveyor[i].diPhotoeye2 AND io.conveyor[i].state = ST_IDLE THEN
			io.conveyor[i].readyToReceive := TRUE;
		ELSE 
			io.conveyor[i].readyToReceive := FALSE;
		END_IF
				
				
		//handshakes for both directions
				
				
		IF i = 0 THEN
			io.conveyor[i].upstreamReadyToSend := io.conveyor[i].diPhotoeye1;
		ELSE 
			io.conveyor[i].upstreamReadyToSend := io.conveyor[i-1].readyToSend;
		END_IF 
					
		IF i = MAI_CONVEYORS THEN
			IF mode = 2 THEN 
				io.conveyor[i].downstreamReadyToReceive := FALSE;
			ELSE
				io.conveyor[i].downstreamReadyToReceive := TRUE;
			END_IF 	
		ELSE 
			io.conveyor[i].downstreamReadyToReceive := io.conveyor[i+1].readyToReceive;
		END_IF
				
		
		CASE io.conveyor[i].state OF 		
			ST_BOOTING:
				// DO NOTHING
				io.conveyor[i].runMotor := FALSE;
				io.conveyor[i].singoutTimer.IN := FALSE;
				io.conveyor[i].singinTimer.IN := FALSE;
				
			ST_IDLE:
				io.conveyor[i].runMotor := FALSE;
				io.conveyor[i].singoutTimer.IN := FALSE;
				io.conveyor[i].singinTimer.IN := FALSE;
				
				IF  io.conveyor[i].upstreamReadyToSend AND io.conveyor[i].readyToReceive THEN 
					io.conveyor[i].state := ST_SINGIN;
				END_IF	
				           
			ST_SINGIN :
						io.conveyor[i].runMotor := TRUE ;
						io.conveyor[i].singinTimer.IN := TRUE;
				
				
						IF io.conveyor[i].diPhotoeye2 THEN
							io.conveyor[i].singinTimer.IN := FALSE;
							io.conveyor[i].runMotor := FALSE;
							io.conveyor[i].singinHoldTimer.IN := TRUE;
								
							IF io.conveyor[i].downstreamReadyToReceive THEN 
								IF mode = 3 AND io.conveyor[i].singinHoldTimer.Q THEN
									io.conveyor[i].state := ST_SINGOUT;
								ELSE 
									io.conveyor[i].state := ST_HOLD;
								END_IF	
							ELSE
								io.conveyor[i].state := ST_HOLD;
				            END_IF
				END_IF
				
						IF 	io.conveyor[i].singinTimer.Q THEN
							io.conveyor[i].state := ST_IDLE;
							io.conveyor[i].singinTimer.IN := FALSE;
						END_IF	
						
			ST_SINGOUT:
				
						io.conveyor[i].runMotor := TRUE;
						io.conveyor[i].singoutTimer.IN := TRUE;
						io.conveyor[i].singinHoldTimer.IN := FALSE;
						
						IF NOT io.conveyor[i].diPhotoeye2 THEN 
							io.conveyor[i].singinTimer.IN := FALSE;	
							io.conveyor[i].runMotor := FALSE;		
							io.conveyor[i].state := ST_IDLE;
						END_IF
                  		    
			ST_HOLD:
				
						io.conveyor[i].runMotor := FALSE;
						io.conveyor[i].singoutTimer.IN := FALSE;
						io.conveyor[i].singinTimer.IN := FALSE;
                        io.conveyor[i].singinHoldTimer.IN := FALSE;				
				
						IF io.conveyor[i].downstreamReadyToReceive THEN
							io.conveyor[i].state := ST_SINGOUT;
						END_IF 
			    
			
		END_CASE 	
		//One shot logic
		io.conveyor[i]._diPhotoeye1 := io.conveyor[i].diPhotoeye1;
		io.conveyor[i]._diPhotoeye2 := io.conveyor[i].diPhotoeye2;
		
	END_FOR
		

	
	// Multiple timers and axis function calls	
	
	spawnTimer(PT:= T#8s);

	
	
END_PROGRAM
