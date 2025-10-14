
TYPE
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
	END_STRUCT;
END_TYPE
