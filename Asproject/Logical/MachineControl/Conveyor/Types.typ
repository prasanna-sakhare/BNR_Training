
TYPE
	edge_Detection_Typ : 	STRUCT 
		_diPhotoeyeExit : BOOL;
		_diPhotoeyeEntrance : BOOL;
		Occupied : BOOL;
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
