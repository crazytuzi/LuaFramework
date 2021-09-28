local LegalWordList = {
  ["破日枪"] = "破月枪",
  ["叫花鸡"] = "叫花花",
  ["飞燕回翔"] = "溅身",
  ["黄色强化符"] = "红色强化符",
  ["甘草"] = "甘花",
  ["鸡肉"] = "猪肉",
  ["分裂攻击"] = "分分攻击",
  ["以牙还牙"] = "借到人人",
  ["逐日战靴"] = "逐月战靴",
  ["草药"] = "药药",
  ["乌草"] = "乌乌",
  ["鱼卵"] = "鱼鱼",
  ["一袋肉干"] = "一袋肉肉",
  ["海魂草"] = "海魂花",
  ["分裂符"] = "分分符"
}
function TestBanword()
  for d, _ in pairs(LegalWordList) do
    local temp = filterChatText_DFAFilter(d)
    print("filterChatText_DFAFilter->> ", temp)
  end
  print("\n")
  for d, _ in pairs(LegalWordList) do
    local temp = checkText_DFAFilter(d)
    print("checkText_DFAFilter->> ", temp)
  end
end
function TestAllLocalDataTable()
  local tempDict = {
    data_Keywords = true,
    data_MissionTalk = true,
    data_NpcInfo = true,
    data_CustomMapPos = true,
    data_NpcFightTalk = true,
    data_ProvinceQuestionLib = true,
    data_Effect = true,
    data_ItemSource = true,
    data_Shop_BuyCoin = true,
    data_CapticalQuestionLib = true,
    data_Market = true,
    data_ZuoqiSkill = true,
    data_Shop_ChongZhi = true,
    data_EquipShowBaseProValue = true,
    data_NpcTypeInfo = true,
    data_Shape = true,
    data_CountryQuestionLib = true,
    data_GiftItem = true,
    data_Chengzhangbd = true,
    data_RbAdden = true,
    data_Mission_Jingying = true,
    data_FunctionUnlock = true,
    data_Shop_BuySilver = true,
    data_MapEffects = true,
    data_Catch = true,
    data_Org_ChumoTask = true,
    data_Org_RenWuLing = true,
    data_DailyHuodongAward = true,
    data_MapLoadingTips = true,
    data_Mission_Branch = true,
    data_ShopHonour = true,
    data_NpcRubbish = true,
    data_TaskRunRing_QuestionLib = true,
    data_Name = true,
    data_TaskRunRing_Talk = true,
    data_AttrTip = true,
    data_Monster = true,
    data_Mission_BangPai = true,
    data_Mission_Activity = true,
    data_EquipShowLianhuaProValue = true,
    data_WarRole = true,
    data_Skill = true,
    data_Mission_Shilian = true,
    data_Org_Huodong = true,
    data_Mission_Guide = true,
    data_Mission_SanJieLiLian = true,
    data_SkillAni = true,
    data_Mission_Main = true
  }
  print([[


==================>>>> checking ...

]])
  for n in pairs(_G) do
    if string.sub(n, 1, 5) == "data_" and tempDict[n] == nil and type(_G[n]) == "table" then
      TestLocalDataTable(n, _G[n])
    end
  end
  print([[


==================>>>> end!!!! ]])
end
function TestLocalDataTable(tbName, tb)
  for k, v in pairs(tb) do
    if type(v) == "table" then
      TestLocalDataTable(tbName, v)
    elseif type(v) == "string" and not checkText_DFAFilter(v) then
      print("---->>检测到不合法字符串:", tbName, v)
      print("---->>检测到不合法字符串:", tbName, filterChatText_DFAFilter(v))
    end
  end
end
