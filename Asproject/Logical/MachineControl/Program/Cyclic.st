
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
    
	convPhotoeyePrev[i].singinTimer();
	convPhotoeyePrev[i].singoutTimer();
	convPhotoeyePrev[i].singinTimer.PT := T#5s;
	convPhotoeyePrev[i].singoutTimer.PT := T#400ms;


	
	CASE mode OF 
		1:
			
	    // Regular mode - Day 1

			FOR i := 0 TO MAI_CONVEYORS DO 
		
				CASE convPhotoeyePrev[i].state OF 		
					ST_IDLE:
					io.conveyor[i].doRunForward := FALSE;
					io.conveyor[i].doRunReverse := FALSE;
					convPhotoeyePrev[i].singoutTimer.IN := FALSE;
					convPhotoeyePrev[i].singinTimer.IN := FALSE;
				
					IF  io.conveyor[i].diPhotoeyeEntrance AND NOT io.conveyor[i].diPhotoeyeExit THEN 
						convPhotoeyePrev[i].state := ST_SINGIN;
					END_IF	
				
				ST_SINGIN :
					io.conveyor[i].doRunForward := TRUE;
					convPhotoeyePrev[i].singinTimer.IN := TRUE;
				
				
					IF io.conveyor[i].diPhotoeyeExit THEN
				    	IF i = 4 THEN 
							convPhotoeyePrev[i].state := ST_HOLD;
							convPhotoeyePrev[i].singinTimer.IN := FALSE;
						ELSIF convPhotoeyePrev[i+1].state = ST_HOLD THEN      
							convPhotoeyePrev[i].state := ST_HOLD;
							convPhotoeyePrev[i].singinTimer.IN := FALSE;
			        	ELSIF NOT io.conveyor[i+1].diPhotoeyeExit  THEN
							convPhotoeyePrev[i].state := ST_SINGOUT;
							convPhotoeyePrev[i].singinTimer.IN := FALSE;
	                	END_IF 
					END_IF 
				
				ST_SINGOUT:
				
					io.conveyor[i].doRunForward := TRUE;
					convPhotoeyePrev[i].singoutTimer.IN := TRUE;
				// This is to test remote branch work
				
					IF i = MAI_CONVEYORS AND io.conveyor[i].diPhotoeyeExit THEN
						convPhotoeyePrev[i].state := ST_HOLD;
					ELSIF io.conveyor[i+1].diPhotoeyeEntrance AND NOT io.conveyor[i+1].diPhotoeyeEntrance THEN   // checks for falling edge on exit eye unless its last conveyor	
						convPhotoeyePrev[i].singoutTimer.IN := FALSE;
						convPhotoeyePrev[i].state := ST_IDLE;
					ELSIF convPhotoeyePrev[i].singoutTimer.Q THEN
					  convPhotoeyePrev[i].singoutTimer.IN := FALSE;
					  convPhotoeyePrev[i].state := ST_IDLE;
					END_IF
                  		    
				ST_HOLD:
				
					io.conveyor[i].doRunForward := FALSE;
					io.conveyor[i].doRunReverse := FALSE;
					convPhotoeyePrev[i].singoutTimer.IN := FALSE;
			    	convPhotoeyePrev[i].singinTimer.IN := FALSE;
				
				
					IF i = MAI_CONVEYORS AND io.conveyor[i].diPhotoeyeExit THEN
						convPhotoeyePrev[i].state := ST_HOLD;
					ELSIF NOT io.conveyor[i+1].diPhotoeyeExit  THEN 
						convPhotoeyePrev[i].state := ST_SINGOUT;
					ELSIF NOT io.conveyor[i].diPhotoeyeExit THEN 
						convPhotoeyePrev[i].state := ST_IDLE;
					END_IF 
			    
			
				END_CASE 	
			
				convPhotoeyePrev[i]._diPhotoeyeEntrance := io.conveyor[i].diPhotoeyeEntrance;
				convPhotoeyePrev[i]._diPhotoeyeExit := io.conveyor[i].diPhotoeyeExit;
		
			END_FOR
		2:
			
			// toggle between forward reverse
		   
			io.spawnCase := TRUE;
			
			// Handshakes
			
			
			
			FOR i := 0 TO MAI_CONVEYORS DO 
				// Handshakes	
				
				
				CASE io.conveyor[i].state OF 		
					ST_IDLE:
						io.conveyor[i].doRunForward := FALSE;
						io.conveyor[i].doRunReverse := FALSE;
						convPhotoeyePrev[i].singoutTimer.IN := FALSE;
						convPhotoeyePrev[i].singinTimer.IN := FALSE;
				
						IF  io.conveyor[i-1].upstreamReadyToSend AND io.conveyor[i].readyToReceive THEN 
							io.conveyor[i].state := ST_SINGIN;
						END_IF	
				           
					ST_SINGIN :
						io.conveyor[i].doRunForward := TRUE;
						io.conveyor[i].singinTimer.IN := TRUE;
				
				
						IF io.conveyor[i].diPhotoeye2 THEN
						    convPhotoeyePrev[i].singinTimer.IN := FALSE;
					        io.conveyor[i].readyToSend := TRUE;
						END_IF 
				
					ST_SINGOUT:
				
						io.conveyor[i].doRunForward := TRUE;
						convPhotoeyePrev[i].singoutTimer.IN := TRUE;
						// This is to test remote branch work
				
						IF i = MAI_CONVEYORS AND io.conveyor[i].diPhotoeyeExit THEN
							convPhotoeyePrev[i].state := ST_HOLD;
						ELSIF io.conveyor[i+1].diPhotoeyeEntrance AND NOT io.conveyor[i+1].diPhotoeyeEntrance THEN   // checks for falling edge on exit eye unless its last conveyor	
							convPhotoeyePrev[i].singoutTimer.IN := FALSE;
							convPhotoeyePrev[i].state := ST_IDLE;
						ELSIF convPhotoeyePrev[i].singoutTimer.Q THEN
							convPhotoeyePrev[i].singoutTimer.IN := FALSE;
							convPhotoeyePrev[i].state := ST_IDLE;
						END_IF
                  		    
					ST_HOLD:
				
						io.conveyor[i].doRunForward := FALSE;
						io.conveyor[i].doRunReverse := FALSE;
						convPhotoeyePrev[i].singoutTimer.IN := FALSE;
						convPhotoeyePrev[i].singinTimer.IN := FALSE;
				
				
						IF i = MAI_CONVEYORS AND io.conveyor[i].diPhotoeyeExit THEN
							convPhotoeyePrev[i].state := ST_HOLD;
						ELSIF NOT io.conveyor[i+1].diPhotoeyeExit  THEN 
							convPhotoeyePrev[i].state := ST_SINGOUT;
						ELSIF NOT io.conveyor[i].diPhotoeyeExit THEN 
							convPhotoeyePrev[i].state := ST_IDLE;
						END_IF 
			    
			
				END_CASE 	
			
				convPhotoeyePrev[i]._diPhotoeyeEntrance := io.conveyor[i].diPhotoeyeEntrance;
				convPhotoeyePrev[i]._diPhotoeyeExit := io.conveyor[i].diPhotoeyeExit;
		
			END_FOR
		  	
			
			
			
			
		3:  
	END_CASE
	
	
	
	
	
END_PROGRAM
