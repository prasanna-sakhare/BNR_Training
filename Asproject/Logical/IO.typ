
TYPE
	IO_Pusher_typ : 	STRUCT 
		aoActualPosition : REAL;
		diPusherExtended : BOOL;
		diPusherRetracted : BOOL;
	END_STRUCT;
	IO_typ : 	STRUCT 
		conveyor : ARRAY[0..MAI_CONVEYORS]OF IO_Conveyor_typ;
		spawnCase : BOOL;
		pusher : IO_Pusher_typ;
	END_STRUCT;
	StateEnum : 
		(
		ST_SINGOUT,
		ST_SINGIN,
		ST_IDLE,
		ST_HOLD
		);
	IO_Conveyor_typ : 	STRUCT 
		diPhotoeyeEntrance : BOOL;
		diPhotoeyeExit : BOOL;
		doRunForward : BOOL;
		doRunReverse : BOOL;
		_diPhotoeye2 : BOOL;
		_diPhotoeye1 : BOOL;
		singoutTimer : TON;
		singinTimer : TON;
		state : StateEnum;
		diPhotoeye2 : BOOL;
		diPhotoeye1 : BOOL;
		downstreamReadyToReceive : BOOL;
		upstreamReadyToSend : BOOL;
		readyToReceive : BOOL;
		readyToSend : BOOL;
		runMotor : BOOL;
		singinHoldTimer : TON;
		aoRunSpeed : REAL;
	END_STRUCT;
END_TYPE
