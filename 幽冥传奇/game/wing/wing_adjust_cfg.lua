
--人物在走动的时候羽翼旋转角度索引是羽翼res_id
WingRotate = {
	[0] = {Walk = 8,  Ride = 8},
	[1] = {Walk = 12,  Ride = 10},
	[2] = {Walk = 12,  Ride = 10}, 
	[3] = {Walk = 12,  Ride = 10},
	[4] = {Walk = 12,  Ride = 10},
	[5] = {Walk = 12, Ride = 10},
	[6] = {Walk = 15, Ride = 12},
	[7] = {Walk = 12, Ride = 8},
	[8] = {Walk = 12, Ride = 8},
	[51] = {Walk = 12, Ride = 8},
	[52] = {Walk = 15, Ride = 12},
}


--羽翼的位移调整
WingAdjust = WingAdjust or {}
WingAdjust[GameEnum.ROLE_PROF_1] = {
	[0] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Stand = { [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[1] = { Walk = {  [GameMath.DirUp] = {x = 5, y = 8},  [GameMath.DirDown] = {x = -4, y = 0}, [GameMath.DirLeft] = {x = 10, y = 5},  [GameMath.DirRight] = {x = -10, y = 5}}, 
			Stand = { [GameMath.DirUp] = {x = 2, y = 5},  [GameMath.DirDown] = {x = -4, y = 10}, [GameMath.DirLeft] = {x = 2, y = 5},  [GameMath.DirRight] = {x = -2, y = 5}},
			Ride = {  [GameMath.DirUp] = {x = 2, y = 15},  [GameMath.DirDown] = {x = -4, y = 15}, [GameMath.DirLeft] = {x = 15, y = 10},  [GameMath.DirRight] = {x = -15, y = 10}}},
	[2] = { Walk = {  [GameMath.DirUp] = {x = 5, y = 15},  [GameMath.DirDown] = {x = -2, y = 15}, [GameMath.DirLeft] = {x = 15, y = 15},  [GameMath.DirRight] = {x = -15, y = 15}}, 
			Stand = { [GameMath.DirUp] = {x = 2, y = 15},  [GameMath.DirDown] = {x = -2, y = 15}, [GameMath.DirLeft] = {x = 3, y = 15},  [GameMath.DirRight] = {x = -3, y = 15}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 15},  [GameMath.DirDown] = {x = -2, y = 15}, [GameMath.DirLeft] = {x = 15, y = 15},  [GameMath.DirRight] = {x = -15, y = 15}}},
	[3] = { Walk = {  [GameMath.DirUp] = {x = 5, y = 10},  [GameMath.DirDown] = {x = -8, y = 0}, [GameMath.DirLeft] = {x = 10, y = 0},  [GameMath.DirRight] = {x = -10, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 5, y = 5},  [GameMath.DirDown] = {x = -6, y = 5}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 15},  [GameMath.DirDown] = {x = 0, y = 0}, [GameMath.DirLeft] = {x = 10, y = 0},  [GameMath.DirRight] = {x = -10, y = 0}}},
	[4] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0}, [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 8, y = 0},  [GameMath.DirRight] = {x = -8, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = -3, y = 0}, [GameMath.DirDown] = {x = -3, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -3, y = 0}, [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 13, y = 0}, [GameMath.DirRight] = {x = -13, y = 0}}},
	[5] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 2, y = 0}, [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = -2, y = 10},  [GameMath.DirDown] = {x = 0, y = 5}, [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -7, y = 10},  [GameMath.DirDown] = {x = 2, y = 0}, [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[6] = { Walk = {  [GameMath.DirUp] = {x = 3, y = 0},  [GameMath.DirDown] = {x = -5, y = 0},  [GameMath.DirLeft] = {x = 15, y = 0}, [GameMath.DirRight] = {x = -15, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 2, y = 0},  [GameMath.DirDown] = {x = -5, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 18, y = 0}, [GameMath.DirRight] = {x = -18, y = 0}}},
	[7] = { Walk = {  [GameMath.DirUp] = {x = 5, y = 10},  [GameMath.DirDown] = {x = -8, y = 0}, [GameMath.DirLeft] = {x = 13, y = 0},  [GameMath.DirRight] = {x = -13, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 5, y = 10},  [GameMath.DirDown] = {x = -8, y = 0}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x =-5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 15},  [GameMath.DirDown] = {x = -3, y = 0},  [GameMath.DirLeft] = {x = 13, y = 0},  [GameMath.DirRight] = {x = -13, y = 0}}},
	[8] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}},
			Stand = { [GameMath.DirUp] = {x = -2, y = 5},  [GameMath.DirDown] = {x = 5, y = 0},  [GameMath.DirLeft] = {x = 3, y = 0},  [GameMath.DirRight] = {x = -3, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -5, y = 15},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 2, y = 0},  [GameMath.DirRight] = {x = -2, y = 0}}},
	[51] = { Walk = {  [GameMath.DirUp] = {x = 5, y = 15},  [GameMath.DirDown] = {x = -2, y = 0}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 15},  [GameMath.DirDown] = {x = -2, y = 0}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 15},  [GameMath.DirDown] = {x = -2, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[52] = { Walk = {  [GameMath.DirUp] = {x = 3, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}},
			Stand = { [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -2, y = 10},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
}

WingAdjust[GameEnum.ROLE_PROF_2] = {
	[0] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Stand = { [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[1] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 10, y = 0},  [GameMath.DirRight] = {x = -10, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 10},  [GameMath.DirLeft] = {x = 2, y = 0},  [GameMath.DirRight] = {x = -2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 10},  [GameMath.DirLeft] = {x = 10, y = 0},  [GameMath.DirRight] = {x = -10, y = 0}}},
	[2] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 8, y = 10},  [GameMath.DirRight] = {x = -8, y = 10}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 10},  [GameMath.DirLeft] = {x = 3, y = 10},  [GameMath.DirRight] = {x = -3, y = 10}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 10},  [GameMath.DirDown] = {x = 0, y = 10},  [GameMath.DirLeft] = {x = 8, y = 10},  [GameMath.DirRight] = {x = -8, y = 10}}},
	[3] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = -2, y = 0}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = -3, y = 0}, [GameMath.DirLeft] = {x = -5, y = 0},  [GameMath.DirRight] = {x = 5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = -3, y = 0}, [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}}},
	[4] = { Walk = {  [GameMath.DirUp] = {x = -5, y = 0}, [GameMath.DirDown] = {x = 5, y = 0},  [GameMath.DirLeft] = {x = 6, y = 0},  [GameMath.DirRight] = {x = -6, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = -5, y = 0}, [GameMath.DirDown] = {x = 5, y = 0},  [GameMath.DirLeft] = {x = -3, y = 0},  [GameMath.DirRight] = {x = 3, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -5, y = 0}, [GameMath.DirDown] = {x = 5, y = 0},  [GameMath.DirLeft] = {x = 4, y = 0},  [GameMath.DirRight] = {x = -4, y = 0}}},
	[5] = { Walk = {  [GameMath.DirUp] = {x = -5, y = 5},  [GameMath.DirDown] = {x = 5, y = -10},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = -3, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = -4, y = 0}, [GameMath.DirRight] = {x = 4, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -5, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = -3, y = 0}, [GameMath.DirRight] = {x = 3, y = 0}}},
	[6] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0}, [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 14, y = 0}, [GameMath.DirRight] = {x = -14, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 0}, [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = -2, y = 0},  [GameMath.DirRight] = {x = 2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -3, y = 0}, [GameMath.DirDown] = {x = 3, y = 0},  [GameMath.DirLeft] = {x = 15, y = 0}, [GameMath.DirRight] = {x = -15, y = 0}}},
	[7] = { Walk = {  [GameMath.DirUp] = {x = 2, y = 5},  [GameMath.DirDown] = {x = -2, y = -5},  [GameMath.DirLeft] = {x = 3, y = 0},  [GameMath.DirRight] = {x = -3, y = 0}}, 
			Stand = { [GameMath.DirUp] = {x = 2, y = 5},  [GameMath.DirDown] = {x = -3, y = 0},  [GameMath.DirLeft] = {x = -5, y = 0}, [GameMath.DirRight] = {x = 5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 3, y = 0},  [GameMath.DirRight] = {x = -3, y = 0}}},
	[8] = { Walk = {  [GameMath.DirUp] = {x = -5, y = 5},  [GameMath.DirDown] = {x = 5, y = -10},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Stand = { [GameMath.DirUp] = {x = -2, y = 5},  [GameMath.DirDown] = {x = 3, y = 0},  [GameMath.DirLeft] = {x = -5, y = 0},  [GameMath.DirRight] = {x = 5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -2, y = 5},  [GameMath.DirDown] = {x = 3, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[51] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}},
			Stand = { [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = -5, y = 0},  [GameMath.DirRight] = {x = 5, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 5, y = 0},  [GameMath.DirRight] = {x = -5, y = 0}}},
	[52] = { Walk = {  [GameMath.DirUp] = {x = -3, y = 0},  [GameMath.DirDown] = {x = 0, y = -5},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Stand = { [GameMath.DirUp] = {x = -3, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = -10, y = 0},  [GameMath.DirRight] = {x = 10, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -3, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
}

WingAdjust[GameEnum.ROLE_PROF_3] = {
	[0] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Stand = { [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 0},  [GameMath.DirDown] = {x = 0, y = 0},  [GameMath.DirLeft] = {x = 0, y = 0},  [GameMath.DirRight] = {x = 0, y = 0}}},
	[1] = { Walk = {  [GameMath.DirUp] = {x = 7, y = 10},  [GameMath.DirDown] = {x = -2, y = 8},  [GameMath.DirLeft] = {x = 8, y = 3},  [GameMath.DirRight] = {x = -8, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 5},  [GameMath.DirDown] = {x = -3, y = 8},  [GameMath.DirLeft] = {x = 4, y = 0},  [GameMath.DirRight] = {x = -4, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 4, y = 10},  [GameMath.DirDown] = {x = -2, y = 8},  [GameMath.DirLeft] = {x = 6, y = 3},  [GameMath.DirRight] = {x = -6, y = 3}}},
	[2] ={ Walk = {  [GameMath.DirUp] = {x = 7, y = 15},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 8, y = 3},  [GameMath.DirRight] = {x = -8, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 5},  [GameMath.DirDown] = {x = -3, y = 12},  [GameMath.DirLeft] = {x = 4, y = 0},  [GameMath.DirRight] = {x = -4, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 4, y = 15},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 6, y = 3},  [GameMath.DirRight] = {x = -6, y = 3}}},
	[3] = { Walk = {  [GameMath.DirUp] = {x = 6, y = 7},  [GameMath.DirDown] = {x = -4, y = 6},  [GameMath.DirLeft] = {x = 8, y = -10},  [GameMath.DirRight] = {x = -8, y = -10}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 5},  [GameMath.DirDown] = {x = -3, y = 6},  [GameMath.DirLeft] = {x = -4, y = -8},  [GameMath.DirRight] = {x = 4, y = -8}},
			Ride = {  [GameMath.DirUp] = {x = 4, y = 7},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 6, y = -10},  [GameMath.DirRight] = {x = -6, y = -10}}},
	[4] ={ Walk = {  [GameMath.DirUp] = {x = 1, y = 2},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = 8, y = 3},  [GameMath.DirRight] = {x = -8, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = -1, y = 2},  [GameMath.DirDown] = {x = 1, y = 6},  [GameMath.DirLeft] = {x = 2, y = 0},  [GameMath.DirRight] = {x = -2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = -1, y = 2},  [GameMath.DirDown] = {x = 2, y = 6},  [GameMath.DirLeft] = {x = 6, y = 3},  [GameMath.DirRight] = {x = -6, y = 3}}},
	[5] = { Walk = {  [GameMath.DirUp] = {x = 0, y = 2},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = 5, y = -3},  [GameMath.DirRight] = {x = -5, y = -3}}, 
			Stand = { [GameMath.DirUp] = {x = 0, y = 2},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = -2, y = -3},  [GameMath.DirRight] = {x = 2, y = -3}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 2},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = 3, y = -2},  [GameMath.DirRight] = {x = -3, y = -2}}},
	[6] ={ Walk = {  [GameMath.DirUp] = {x = 5, y = 2},  [GameMath.DirDown] = {x = -3, y = 4},  [GameMath.DirLeft] = {x = 8, y = 3},  [GameMath.DirRight] = {x = -8, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 2},  [GameMath.DirDown] = {x = -3, y = 6},  [GameMath.DirLeft] = {x = 2, y = 0},  [GameMath.DirRight] = {x = -2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 2, y = 2},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 6, y = 3},  [GameMath.DirRight] = {x = -6, y = 3}}},
	[7] = { Walk = {  [GameMath.DirUp] = {x = 6, y = 7},  [GameMath.DirDown] = {x = -4, y = 6},  [GameMath.DirLeft] = {x = 6, y = 3},  [GameMath.DirRight] = {x = -6, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 7},  [GameMath.DirDown] = {x = -3, y = 6},  [GameMath.DirLeft] = {x = -1, y = 0},  [GameMath.DirRight] = {x = 1, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 2, y = 7},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 4, y = 3},  [GameMath.DirRight] = {x = 4, y = 3}}},
	[8] ={ Walk = {  [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = 5, y = 3},  [GameMath.DirRight] = {x = -5, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = -1, y = 5},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = -2, y = 0},  [GameMath.DirRight] = {x = 2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 0, y = 5},  [GameMath.DirDown] = {x = 0, y = 6},  [GameMath.DirLeft] = {x = 3, y = 3},  [GameMath.DirRight] = {x = -3, y = 3}}},
	[51] = { Walk = {  [GameMath.DirUp] = {x = 3, y = 2},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 8, y = 3},  [GameMath.DirRight] = {x = -8, y = 3}}, 
			Stand = { [GameMath.DirUp] = {x = 3, y = 2},  [GameMath.DirDown] = {x = -3, y = 6},  [GameMath.DirLeft] = {x = 2, y = 0},  [GameMath.DirRight] = {x = -2, y = 0}},
			Ride = {  [GameMath.DirUp] = {x = 2, y = 2},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = 3, y = 3},  [GameMath.DirRight] = {x = -3, y = 3}}},
	[52] ={ Walk = {  [GameMath.DirUp] = {x = 4, y = 7},  [GameMath.DirDown] = {x = -1, y = 6},  [GameMath.DirLeft] = {x = 6, y = -5},  [GameMath.DirRight] = {x = -6, y = -5}}, 
			Stand = { [GameMath.DirUp] = {x = 2, y = 2},  [GameMath.DirDown] = {x = -2, y = 6},  [GameMath.DirLeft] = {x = -5, y = -5},  [GameMath.DirRight] = {x = 5, y = -5}},
			Ride = {  [GameMath.DirUp] = {x = 2, y = 7},  [GameMath.DirDown] = {x = -1, y = 6},  [GameMath.DirLeft] = {x = 2, y = -5},  [GameMath.DirRight] = {x = -2, y = -5}}},
}
