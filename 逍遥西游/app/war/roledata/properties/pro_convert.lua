PROPERTIES_SVRKEY = {
  [PROPERTY_FREEPOINT] = "i_pt",
  [PROPERTY_ROLELEVEL] = "i_lv",
  [PROPERTY_ZHUANSHENG] = "i_rebirth",
  [PROPERTY_EXP] = "i_exp",
  [PROPERTY_GENDER] = "i_sex",
  [PROPERTY_NAME] = "s_name",
  [PROPERTY_GenGu] = "i_gg",
  [PROPERTY_Lingxing] = "i_lx",
  [PROPERTY_LiLiang] = "i_ll",
  [PROPERTY_MinJie] = "i_mj",
  [PROPERTY_PETID] = "i_bpet",
  [PROPERTY_ISBANGDING] = "i_bd",
  [PROPERTY_Wing_GenGu] = "i_cbgg",
  [PROPERTY_Wing_Lingxing] = "i_cblx",
  [PROPERTY_Wing_LiLiang] = "i_cbll",
  [PROPERTY_Wing_MinJie] = "i_cbmj",
  [PROPERTY_LONGGU_NUM] = "i_ngbone",
  [PROPERTY_LIANYAO_NUM] = "i_lyn",
  [PROPERTY_CLOSEVALUE] = "i_close",
  [PROPERTY_PETSKILLS] = "t_skills",
  [PROPERTY_SSSKILLS] = "t_ss",
  [PROPERTY_ZJSKILLSEXP] = "t_skillpro",
  [PROPERTY_RANDOM_GROWUP] = "i_grand",
  [PROPERTY_RANDOM_HPBASE] = "i_hprand",
  [PROPERTY_RANDOM_MPBASE] = "i_mprand",
  [PROPERTY_RANDOM_APBASE] = "i_aprand",
  [PROPERTY_RANDOM_SPBASE] = "i_sprand",
  [PROPERTY_LONGGU_ADDHP] = "i_bhp",
  [PROPERTY_LONGGU_ADDMP] = "i_bmp",
  [PROPERTY_LONGGU_ADDAP] = "i_bap",
  [PROPERTY_LONGGU_ADDSP] = "i_bsp",
  [PROPERTY_HUAJING_NUM] = "i_hj",
  [PROPERTY_HUAJING_ADDPRONUM] = "i_hjcz",
  [PROPERTY_HUALING_NUM] = "i_hl",
  [PROPERTY_PETLIANHUA_PDEFEND] = "i_k1",
  [PROPERTY_PETLIANHUA_KFENG] = "i_k2",
  [PROPERTY_PETLIANHUA_KHUO] = "i_k3",
  [PROPERTY_PETLIANHUA_KSHUI] = "i_k4",
  [PROPERTY_PETLIANHUA_KLEI] = "i_k5",
  [PROPERTY_PETLIANHUA_KHUNLUAN] = "i_k6",
  [PROPERTY_PETLIANHUA_KFENGYIN] = "i_k7",
  [PROPERTY_PETLIANHUA_KHUNSHUI] = "i_k8",
  [PROPERTY_PETLIANHUA_KZHONGDU] = "i_k9",
  [PROPERTY_PETLIANHUA_KZHENSHE] = "i_k10",
  [PROPERTY_PETLIANHUA_KAIHAO] = "i_k11",
  [PROPERTY_PETLIANHUA_KYIWANG] = "i_k12",
  [PROPERTY_STARPOINT] = "i_sn",
  [PROPERTY_ZSTYPELIST] = "t_zs",
  [PROPERTY_ZSNUMLIST] = "t_zsa",
  [PROPERTY_ZUOQI_GenGu] = "i_zqgg",
  [PROPERTY_ZUOQI_Lingxing] = "i_zqlx",
  [PROPERTY_ZUOQI_LiLiang] = "i_zqll",
  [PROPERTY_ZUOQI_INIT_GenGu] = "i_zqigg",
  [PROPERTY_ZUOQI_INIT_Lingxing] = "i_zqilx",
  [PROPERTY_ZUOQI_INIT_LiLiang] = "i_zqill",
  [PROPERTY_ZUOQI_DIANHUA] = "i_zqdh",
  [PROPERTY_ZUOQI_SKILLPVALUE] = "i_zqskp",
  [PROPERTY_ZUOQI_CDTIME] = "i_cdtime",
  [PROPERTY_WARAUTOSKILL] = "i_auto",
  [PROPERTY_ZuoqiRideState] = "i_fight"
}
SVRKEY_PROPERTIES = {}
for k, v in pairs(PROPERTIES_SVRKEY) do
  SVRKEY_PROPERTIES[v] = k
end
PROPERTIES_RANDOM_KANG = {
  [0] = PROPERTY_PDEFEND,
  [1] = PROPERTY_KFENG,
  [2] = PROPERTY_KHUO,
  [3] = PROPERTY_KSHUI,
  [4] = PROPERTY_KLEI,
  [5] = PROPERTY_KHUNLUAN,
  [6] = PROPERTY_KFENGYIN,
  [7] = PROPERTY_KHUNSHUI,
  [8] = PROPERTY_KZHONGDU,
  [9] = PROPERTY_KZHENSHE,
  [10] = PROPERTY_KAIHAO,
  [11] = PROPERTY_KYIWANG,
  [12] = PROPERTY_KXIXUE
}
PROPERTIES_RANDOM_KANG_REVERSE = {}
for k, v in pairs(PROPERTIES_RANDOM_KANG) do
  PROPERTIES_RANDOM_KANG_REVERSE[v] = k
end
PROPERTIES_STRENGTHEN_MAGIC = {
  [0] = PROPERTY_QHSH,
  [1] = PROPERTY_STRENGTHEN_MAGIC_FENG,
  [2] = PROPERTY_STRENGTHEN_MAGIC_HUO,
  [3] = PROPERTY_STRENGTHEN_MAGIC_SHUI,
  [4] = PROPERTY_STRENGTHEN_MAGIC_LEI,
  [5] = PROPERTY_STRENGTHEN_MAGIC_HUNLUAN_RATE,
  [6] = PROPERTY_STRENGTHEN_MAGIC_FENGYIN_RATE,
  [7] = PROPERTY_STRENGTHEN_MAGIC_HUNSHUI_RATE,
  [8] = PROPERTY_STRENGTHEN_MAGIC_DU_RATE,
  [9] = PROPERTY_STRENGTHEN_MAGIC_ZHEN,
  [10] = PROPERTY_STRENGTHEN_MAGIC_AIHAO,
  [11] = PROPERTY_STRENGTHEN_MAGIC_YIWANG_RATE,
  [12] = PROPERTY_STRENGTHEN_MAGIC_XIXUE
}
function ConvertPropertiesToSvrkey(inTable, outTable)
  if outTable == nil then
    outTable = {}
  end
  for k, v in pairs(PROPERTIES_SVRKEY) do
    outTable[v] = inTable[k]
  end
  return outTable
end
function ConvertSvrkeyToProperties(inTable, outTable)
  if outTable == nil then
    outTable = {}
  end
  for k, v in pairs(PROPERTIES_SVRKEY) do
    outTable[k] = inTable[v]
  end
  return outTable
end
