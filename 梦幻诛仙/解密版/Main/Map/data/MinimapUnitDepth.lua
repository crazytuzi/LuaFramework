local Depths = {
  Floor = 0,
  VeryLow = 10,
  Low = 30,
  Normal = 50,
  High = 70,
  VeryHigh = 90,
  Ceil = 100
}
Depths.TracePoint = Depths.VeryLow
Depths.TraceTarget = Depths.VeryLow + 1
Depths.NPCPoint = Depths.Low
Depths.HeroAvatar = Depths.Low + 1
Depths.NPCLabel = Depths.Normal
Depths.Transfer = Depths.Normal
Depths.bf_flag_img = Depths.VeryLow - 4
Depths.bf_flag_name = Depths.VeryLow - 3
Depths.bf_buff = Depths.VeryLow - 2
Depths.bf_res = Depths.VeryLow - 1
Depths.bf_role = Depths.VeryLow + 1
return Depths
