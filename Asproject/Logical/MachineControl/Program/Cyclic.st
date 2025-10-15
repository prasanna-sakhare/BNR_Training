
PROGRAM _CYCLIC
	(* Insert code here *)
	
//	IF diPhotoeye = FALSE THEN
//		doPusher := TRUE;
//	END_IF	
	
//	testTimer();
	testTimer.IN := TRUE;
	testTimer.PT := T#1S;
	
	CASE counterState OF
		ST_WAIT:
		     IF testTimer.Q THEN 
					counterState := ST_RUNNING;
			END_IF
			
	    ST_RUNNING:
			    counter := counter + 1;
				testTimer.IN := FALSE;
			    counterState := ST_WAIT;
	END_CASE
    //test :=  counter MOD 10;
	//myCommand := (test = 0) AND (counter<200)
    
	io.conveyor[i].singinTimer();
	io.conveyor[i].singoutTimer();
	spawnTimer();
	spawnTimer.PT:= T#6s;
	io.conveyor[i].singinTimer.PT := T#5s;
	io.conveyor[i].singoutTimer.PT := T#400ms;

	mode := 1;
	
	CASE mode OF 
		1:
			
	    // Regular mode - Day 1

			IF spawnTimer.Q AND NOT io.conveyor[0].diPhotoeyeEntrance THEN
				io.spawnCase := TRUE;
				spawnTimer.IN := FALSE;
			ELSE
				io.spawnCase := FALSE;
				spawnTimer.IN := TRUE;
			END_IF	
			// Handshakes
			
			FOR i := 0 TO MAI_CONVEYORS DO 
				
				// defining signals
				    io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeEntrance;
					io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeExit;
					io.conveyor[i].doRunForward := io.conveyor[i].runMotor;
					io.conveyor[i].doRunReverse := FALSE;
			
				
				IF io.conveyor[i].diPhotoeye2 THEN
					io.conveyor[i].readyToSend := TRUE;
				ELSE 
					io.conveyor[i].readyToSend := FALSE;
				END_IF	
				
				IF NOT io.conveyor[i].diPhotoeye2 THEN
					io.conveyor[i].readyToReceive := TRUE;
				ELSE 
					io.conveyor[i].readyToReceive := FALSE;
				END_IF
				
				
				
				// handshakes for both directions
				
				
					IF i = 0 THEN
						io.conveyor[i].upstreamReadyToSend := io.conveyor[i].diPhotoeye1;
					ELSE 
						io.conveyor[i].upstreamReadyToSend := io.conveyor[i-1].readyToSend;
					END_IF 
						
					IF i = MAI_CONVEYORS THEN
						io.conveyor[i].downstreamReadyToReceive := FALSE;
					ELSE 
						io.conveyor[i].downstreamReadyToReceive := io.conveyor[i+1].readyToReceive;
					END_IF
				
				
				CASE io.conveyor[i].state OF 		
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
							convPhotoeyePrev[i].singinTimer.IN := FALSE;
							io.conveyor[i].runMotor := FALSE;
							IF io.conveyor[i].downstreamReadyToReceive THEN
								io.conveyor[i].state := ST_SINGOUT;
							ELSE 
								io.conveyor[i].state := ST_HOLD;
							END_IF	
						END_IF 
				         
					ST_SINGOUT:
				
						io.conveyor[i].runMotor := TRUE;
						io.conveyor[i].singoutTimer.IN := TRUE;
				
						IF NOT io.conveyor[i].diPhotoeye2 THEN 
							io.conveyor[i].singinTimer.IN := FALSE;	
							io.conveyor[i].runMotor := FALSE;		
							io.conveyor[i].state := ST_IDLE;
						END_IF
                  		    
					ST_HOLD:
				
						io.conveyor[i].runMotor := FALSE;
						io.conveyor[i].singoutTimer.IN := FALSE;
						io.conveyor[i].singinTimer.IN := FALSE;
				
				
						IF io.conveyor[i].downstreamReadyToReceive THEN
							io.conveyor[i].state := ST_SINGOUT;
						END_IF 
			    
			
				END_CASE 	
			
				io.conveyor[i]._diPhotoeye1 := io.conveyor[i].diPhotoeye1;
				io.conveyor[i]._diPhotoeye2 := io.conveyor[i].diPhotoeye2;
		
			END_FOR
		2:
			
			// toggle between forward reverse
		   
			//io.spawnCase := TRUE;
			// Logic to change box direction when it hits last zone on each side
				
			IF io.conveyor[0].diPhotoeyeEntrance THEN
				direction := TRUE;
			END_IF 
			
			IF io.conveyor[3].diPhotoeyeExit THEN
				direction := FALSE;
	     	END_IF	
			// Handshakes
			
			FOR i := 0 TO MAI_CONVEYORS DO 
				
				// direction definition for box
				
				IF direction THEN
					io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeEntrance;
					io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeExit;
					io.conveyor[i].doRunForward := io.conveyor[i].runMotor;
					io.conveyor[i].doRunReverse := FALSE;
				ELSE
					io.conveyor[i].diPhotoeye1 := io.conveyor[i].diPhotoeyeExit;
					io.conveyor[i].diPhotoeye2 := io.conveyor[i].diPhotoeyeEntrance;
					io.conveyor[i].doRunReverse := io.conveyor[i].runMotor;
					io.conveyor[i].doRunForward := FALSE;
				END_IF 
				
				
			
				// 
				
				IF io.conveyor[i].diPhotoeye2 THEN
					io.conveyor[i].readyToSend := TRUE;
				ELSE 
					io.conveyor[i].readyToSend := FALSE;
				END_IF	
				
				IF NOT io.conveyor[i].diPhotoeye2 THEN
					io.conveyor[i].readyToReceive := TRUE;
				ELSE 
					io.conveyor[i].readyToReceive := FALSE;
				END_IF
				
				
				
				// handshakes for both directions
				
				IF direction THEN
						IF i = 0 THEN
					    	io.conveyor[i].upstreamReadyToSend := io.conveyor[i].diPhotoeye1;
						ELSE 
							io.conveyor[i].upstreamReadyToSend := io.conveyor[i-1].readyToSend;
						END_IF 
						
						IF i = MAI_CONVEYORS THEN
							io.conveyor[i].downstreamReadyToReceive := FALSE;
						ELSE 
							io.conveyor[i].downstreamReadyToReceive := io.conveyor[i+1].readyToReceive;
						END_IF 
				ELSE 
					IF i = MAI_CONVEYORS THEN
						io.conveyor[i].upstreamReadyToSend := io.conveyor[i].diPhotoeye2;
					ELSE 
						io.conveyor[i].upstreamReadyToSend := io.conveyor[i+1].readyToSend;
					END_IF 
						
					IF i = 0 THEN
						io.conveyor[i].downstreamReadyToReceive := FALSE;
					ELSE 
						io.conveyor[i].downstreamReadyToReceive := io.conveyor[i-1].readyToReceive;
					END_IF 
				END_IF
				
				
				CASE io.conveyor[i].state OF 		
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
							convPhotoeyePrev[i].singinTimer.IN := FALSE;
							io.conveyor[i].runMotor := FALSE;
							IF io.conveyor[i].downstreamReadyToReceive THEN
								io.conveyor[i].state := ST_SINGOUT;
							ELSE 
								io.conveyor[i].state := ST_HOLD;
							END_IF	
						END_IF 
				         
					ST_SINGOUT:
				
						io.conveyor[i].runMotor := TRUE;
						io.conveyor[i].singoutTimer.IN := TRUE;
				
						IF NOT io.conveyor[i].diPhotoeye2 THEN 
							io.conveyor[i].singinTimer.IN := FALSE;	
							io.conveyor[i].runMotor := FALSE;		
							io.conveyor[i].state := ST_IDLE;
						END_IF
                  		    
					ST_HOLD:
				
						io.conveyor[i].runMotor := FALSE;
						io.conveyor[i].singoutTimer.IN := FALSE;
						io.conveyor[i].singinTimer.IN := FALSE;
				
				
						IF io.conveyor[i].downstreamReadyToReceive THEN
							io.conveyor[i].state := ST_SINGOUT;
						END_IF 
			    
			
				END_CASE 	
			
				io.conveyor[i]._diPhotoeye1 := io.conveyor[i].diPhotoeye1;
				io.conveyor[i]._diPhotoeye2 := io.conveyor[i].diPhotoeye2;
		
			END_FOR
		  	
			
			
			
			
		3:  
		
	END_CASE
	
	
	
	
	
END_PROGRAM
