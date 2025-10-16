
PROGRAM _CYCLIC
	(* Insert code here *)
	Piper_fn_Cyclic(gMachine);
	PiperInterface;
	
	
	
	CASE state OF 
		ST_STOP:
			counter := 0;
			IF startCounting THEN
				state := ST_RUNNING;
			END_IF	
		ST_RUNNING:
				counter := counter +1;
		ST_DONE:
		
		     
	END_CASE
END_PROGRAM
