local Util                  = require "Zeus.Logic.Util"

local MasteryUtil = {}

MasteryUtil.fontColor = 
{
  bai = 0xe7e5d1ff,
  hong = 0xff0000ff,
  lan = 0x448cd5ff,
  chen = 0xef880eff,
  nv = 0x5bc61aff,
  huang = 0xffba00ff
  
}

MasteryUtil.pingzhiColor = 
{
  [1]=Util.GetQualityColorRGBA(1),
  [2]=Util.GetQualityColorRGBA(2),
  [3]=Util.GetQualityColorRGBA(3),
  [4]=Util.GetQualityColorRGBA(4),
  [5]=Util.GetQualityColorRGBA(5),
  [6]=Util.GetQualityColorRGBA(6),
}

MasteryUtil.numToHanzi = {
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocszero"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsone"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocstwo"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsthree"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsfore"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsfive"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocssex"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsseven"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocseight"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsnine"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsten"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocseleven"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocstwelve"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsthirteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsfourteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsfifteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocssixteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsseventeen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocseightteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocsnineteen"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "tocstwenty"),
  ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.MOUNT, "divide_mark"),
}

function MasteryUtil.SplicingMsg(Ostr,value,isFormat)
  local str = Ostr
  local v = value
  local strr = ""
  if str == nil then
    return ""
  end
  if isFormat == 0 then
    strr = string.gsub(str,"{A}",v)
  else
    strr = string.gsub(str,"{A}",(v/100))
  end
  return strr
end

return MasteryUtil
