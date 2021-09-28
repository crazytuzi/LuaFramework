----------------- auto generate db file ------------------------
module(..., package.seeall)

local require = require

local spawn_area = 
{
	[401] = {	id = 401, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4001, 4002, 4003, 4004, 4005, 4006, 4007, 4008, 4009,  } , spawndeny = 0 },
	[402] = {	id = 402, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4011, 4012, 4013, 4014, 4015, 4016, 4017, 4018, 4019,  } , spawndeny = 0 },
	[403] = {	id = 403, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4021, 4022, 4023, 4024, 4025, 4026, 4027, 4028, 4029,  } , spawndeny = 0 },
	[404] = {	id = 404, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4031, 4032, 4033, 4034, 4035, 4036, 4037, 4038, 4039,  } , spawndeny = 0 },
	[411] = {	id = 411, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4101, 4102, 4103, 4104, 4105, 4106, 4107, 4108, 4109,  } , spawndeny = 0 },
	[412] = {	id = 412, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4111, 4112, 4113, 4114, 4115, 4116, 4117, 4118, 4119,  } , spawndeny = 0 },
	[413] = {	id = 413, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4121, 4122, 4123, 4124, 4125, 4126, 4127, 4128, 4129,  } , spawndeny = 0 },
	[414] = {	id = 414, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4131, 4132, 4133, 4134, 4135, 4136, 4137, 4138, 4139,  } , spawndeny = 0 },
	[421] = {	id = 421, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4201, 4202, 4203, 4204, 4205, 4206, 4207, 4208, 4209,  } , spawndeny = 0 },
	[422] = {	id = 422, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4211, 4212, 4213, 4214, 4215, 4216, 4217, 4218, 4219,  } , spawndeny = 0 },
	[423] = {	id = 423, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4221, 4222, 4223, 4224, 4225, 4226, 4227, 4228, 4229,  } , spawndeny = 0 },
	[424] = {	id = 424, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4231, 4232, 4233, 4234, 4235, 4236, 4237, 4238, 4239,  } , spawndeny = 0 },
	[431] = {	id = 431, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4301, 4302, 4303, 4304, 4305, 4306, 4307, 4308, 4309,  } , spawndeny = 0 },
	[432] = {	id = 432, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4311, 4312, 4313, 4314, 4315, 4316, 4317, 4318, 4319,  } , spawndeny = 0 },
	[433] = {	id = 433, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4321, 4322, 4323, 4324, 4325, 4326, 4327, 4328, 4329,  } , spawndeny = 0 },
	[434] = {	id = 434, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4331, 4332, 4333, 4334, 4335, 4336, 4337, 4338, 4339,  } , spawndeny = 0 },
	[441] = {	id = 441, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4401, 4402, 4403, 4404, 4405, 4406, 4407, 4408, 4409,  } , spawndeny = 0 },
	[442] = {	id = 442, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4411, 4412, 4413, 4414, 4415, 4416, 4417, 4418, 4419,  } , spawndeny = 0 },
	[443] = {	id = 443, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4421, 4422, 4423, 4424, 4425, 4426, 4427, 4428, 4429,  } , spawndeny = 0 },
	[444] = {	id = 444, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4431, 4432, 4433, 4434, 4435, 4436, 4437, 4438, 4439,  } , spawndeny = 0 },
	[451] = {	id = 451, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4501, 4502, 4503, 4504, 4505, 4506, 4507, 4508, 4509,  } , spawndeny = 0 },
	[452] = {	id = 452, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4511, 4512, 4513, 4514, 4515, 4516, 4517, 4518, 4519,  } , spawndeny = 0 },
	[453] = {	id = 453, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4521, 4522, 4523, 4524, 4525, 4526, 4527, 4528, 4529,  } , spawndeny = 0 },
	[454] = {	id = 454, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4531, 4532, 4533, 4534, 4535, 4536, 4537, 4538, 4539,  } , spawndeny = 0 },
	[461] = {	id = 461, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4601, 4602, 4603, 4604, 4605, 4606, 4607, 4608, 4609,  } , spawndeny = 0 },
	[462] = {	id = 462, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4610, 4611, 4612, 4613, 4614, 4615, 4616, 4617, 4618,  } , spawndeny = 0 },
	[463] = {	id = 463, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4619, 4620, 4621, 4622, 4623, 4624, 4625, 4626, 4627,  } , spawndeny = 0 },
	[464] = {	id = 464, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4628, 4629, 4630, 4631, 4632, 4633, 4634, 4635, 4636,  } , spawndeny = 0 },
	[471] = {	id = 471, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4701, 4702, 4703, 4704, 4705, 4706, 4707, 4708, 4709,  } , spawndeny = 0 },
	[472] = {	id = 472, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4710, 4711, 4712, 4713, 4714, 4715, 4716, 4717, 4718,  } , spawndeny = 0 },
	[473] = {	id = 473, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4719, 4720, 4721, 4722, 4723, 4724, 4725, 4726, 4727,  } , spawndeny = 0 },
	[474] = {	id = 474, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4728, 4729, 4730, 4731, 4732, 4733, 4734, 4735, 4736,  } , spawndeny = 0 },
	[481] = {	id = 481, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4801, 4802, 4803, 4804, 4805, 4806, 4807, 4808, 4809,  } , spawndeny = 0 },
	[482] = {	id = 482, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4810, 4811, 4812, 4813, 4814, 4815, 4816, 4817, 4818,  } , spawndeny = 0 },
	[483] = {	id = 483, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4819, 4820, 4821, 4822, 4823, 4824, 4825, 4826, 4827,  } , spawndeny = 0 },
	[484] = {	id = 484, range = 1400.0, obstacle = { valid = 0 }, BeginOpen = {  }, BeginClose = {  }, EndOpen = {  }, EndClose = {  }, spawnPoints = { 4828, 4829, 4830, 4831, 4832, 4833, 4834, 4835, 4836,  } , spawndeny = 0 },

};
function get_db_table()
	return spawn_area;
end
