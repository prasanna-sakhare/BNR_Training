
PROGRAM _CYCLIC
	(* Insert code here *)
	
	IF diPhotoeye = FALSE THEN
		doPusher := TRUE;
	END_IF	
	
	testTimer();
	testTimer.IN := TRUE;
	testTimer.PT := T#1S;
	
	
	IF testTimer.Q THEN
		counter := counter + 1;
		testTimer.IN := FALSE;
	END_IF
	
    test :=  counter MOD 10;
	myCommand := (test = 0) AND (counter<200) ;
	
	
	
	currentTimer := T#50S;
	
	
	
	
	FOR i := 0 TO MAI_CONVEYORS DO 
		convPhotoeyePrev[i].singinTimer();
		convPhotoeyePrev[i].singoutTimer();
		convPhotoeyePrev[i].singinTimer.PT := T#5s;
		convPhotoeyePrev[i].singoutTimer.PT := T#400ms;
		
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
	
	
	
	
	
	
END_PROGRAM
