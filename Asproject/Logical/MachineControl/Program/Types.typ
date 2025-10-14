
TYPE
	CountEnum : 
		(
		ST_RUNNING,
		ST_WAIT
		);
	StateEnum : 
		(
		ST_SINGOUT,
		ST_SINGIN,
		ST_IDLE,
		ST_HOLD
		);
	edge_Detection_Typ : 	STRUCT 
		_diPhotoeyeExit : BOOL;
		_diPhotoeyeEntrance : BOOL;
		Occupied : BOOL;
		state : StateEnum;
		Timer : TON;
		singoutTimer : TON;
		singinTimer : TON;
		readyToSend : BOOL;
		upstreamReadyToSend : BOOL;
		downstreamReadyToReceive : BOOL;
		DirectionForward : BOOL;
		readyToReceive : BOOL;
	END_STRUCT;
END_TYPE
