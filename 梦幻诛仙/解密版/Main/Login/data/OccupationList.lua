local GenderEnum = require("consts.mzm.gsp.occupation.confbean.SGenderEnum")
local OccupationEnum = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local MALE = GenderEnum.MALE
local FEMALE = GenderEnum.FEMALE
local occupationList = {
  [OccupationEnum.GUI_WANG_ZONG] = {},
  [OccupationEnum.QIN_GYUN_MEN] = {},
  [OccupationEnum.TIAN_YIN_SI] = {},
  [OccupationEnum.FEN_XIANG_GU] = {},
  [OccupationEnum.HE_HUAN_PAI] = {},
  [OccupationEnum.SHENG_WU_JIAO] = {},
  [OccupationEnum.CANG_YU_GE] = {},
  [OccupationEnum.LING_YIN_DIAN] = {},
  [OccupationEnum.FEN_TIAN_GONG] = {},
  [OccupationEnum.SEN_LUO_DIAN] = {}
}
return occupationList
