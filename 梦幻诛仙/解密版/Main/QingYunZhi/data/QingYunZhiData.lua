local Lplus = require("Lplus")
local Json = require("Utility.json")
local QingYunZhiData = Lplus.Class("QingYunZhiData")
local def = QingYunZhiData.define
local instance
local QINGYUNZHI_TYPE = {
  NORMAL = 1,
  ELITE = 2,
  HERO = 3
}
QingYunZhiData.QINGYUNZHI_TYPE = QINGYUNZHI_TYPE
def.field("table").dataNormalCfg = nil
def.field("table").dataEliteCfg = nil
def.field("table").dataHeroCfg = nil
def.field("table").dataNormalPage = nil
def.field("table").dataElitePage = nil
def.field("table").dataHeroPage = nil
def.field("table").dataHeroInfo = nil
def.field("number").maxNormalPage = 0
def.field("number").maxElitePage = 0
def.field("number").maxHeroPage = 0
def.field("number").maxNodeCount = 5
def.static("=>", QingYunZhiData).Instance = function()
  if not instance then
    instance = QingYunZhiData()
  end
  return instance
end
def.method().InitData = function(self)
  local dataNormalCfg = {}
  local dataEliteCfg = {}
  local dataHeroCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_QINGYUNZHI_CFG)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 0, count - 1 do
    local entry = DynamicDataTable.FastGetRecordByIdx(entries, i)
    local qingyunzhiStruct = DynamicRecord.GetStructValue(entry, "qingyunzhiStruct")
    local npcDlgList = {}
    local npcDlgVectorCount = DynamicRecord.GetVectorSize(qingyunzhiStruct, "dlgVector")
    for i = 0, npcDlgVectorCount - 1 do
      local npcDlgRecord = DynamicRecord.GetVectorValueByIdx(qingyunzhiStruct, "dlgVector", i)
      local dlgDes = npcDlgRecord:GetStringValue("dlgDes")
      local dlgNpcId = npcDlgRecord:GetIntValue("npcId")
      if dlgNpcId > 0 then
        table.insert(npcDlgList, {dlgDes = dlgDes, dlgNpcId = dlgNpcId})
      end
    end
    local data = {
      id = DynamicRecord.GetIntValue(entry, "id"),
      chapterNum = DynamicRecord.GetIntValue(entry, "chapterNum"),
      chapterPicid = DynamicRecord.GetIntValue(entry, "chapterPicid"),
      openLevel = DynamicRecord.GetIntValue(entry, "openLevel"),
      reLevelHigh = DynamicRecord.GetIntValue(entry, "reLevelHigh"),
      reLevellow = DynamicRecord.GetIntValue(entry, "reLevellow"),
      challengeType = DynamicRecord.GetIntValue(entry, "challengeType"),
      sectionNum = DynamicRecord.GetIntValue(entry, "sectionNum"),
      sectionName = DynamicRecord.GetStringValue(entry, "sectionName"),
      sectionPicid = DynamicRecord.GetIntValue(entry, "sectionPicid"),
      modelRet = DynamicRecord.GetIntValue(entry, "modelRet"),
      reFightValue = DynamicRecord.GetIntValue(entry, "reFightValue"),
      roleNumDes = DynamicRecord.GetStringValue(entry, "roleNumDes"),
      sectionDes = DynamicRecord.GetStringValue(entry, "sectionDes"),
      fightCfgId = DynamicRecord.GetIntValue(entry, "fightCfgId"),
      fixAwardId = DynamicRecord.GetIntValue(entry, "fixAwardId"),
      npcDlgListVector = npcDlgList
    }
    if data.challengeType == 1 then
      dataNormalCfg[data.id] = data
    elseif data.challengeType == 2 then
      dataEliteCfg[data.id] = data
    elseif data.challengeType == 3 then
      dataHeroCfg[data.id] = data
    else
      warn("\230\156\170\229\164\132\231\144\134\231\154\132\233\157\146\228\186\145\229\191\151\230\140\145\230\136\152\231\177\187\229\158\139!", data.id)
    end
  end
  DynamicDataTable.FastGetRecordEnd(entries)
  local function getChapterPage(dataCfg)
    local chapterCfg = {}
    for k, v in pairs(dataCfg) do
      local chapter = chapterCfg[v.chapterNum]
      if chapter == nil then
        chapter = {
          id = v.chapterNum
        }
        chapterCfg[v.chapterNum] = chapter
      end
      chapter[v.sectionNum] = v
    end
    local chapterPage = {}
    table.sort(chapterCfg, function(a, b)
      return a.id < b.id
    end)
    for chapterId, chapter in pairs(chapterCfg) do
      local page = {}
      page.chapterId = chapterId
      for nodeId, node in ipairs(chapter) do
        if type(node) == "table" then
          table.insert(page, node)
          if #page >= self.maxNodeCount then
            table.insert(chapterPage, page)
            page = {}
            page.chapterId = chapterId
          end
        end
      end
      if #page > 0 then
        table.insert(chapterPage, page)
      end
    end
    return chapterPage
  end
  self.dataHeroCfg = dataHeroCfg
  self.dataEliteCfg = dataEliteCfg
  self.dataNormalCfg = dataNormalCfg
  self.dataHeroPage = getChapterPage(dataHeroCfg)
  self.dataElitePage = getChapterPage(dataEliteCfg)
  self.dataNormalPage = getChapterPage(dataNormalCfg)
  self.maxNormalPage = #self.dataNormalPage
  self.maxElitePage = #self.dataElitePage
  self.maxHeroPage = #self.dataHeroPage
  self.dataHeroInfo = {
    normalCurChapter = 0,
    normalCurSection = 0,
    normalNextPage = 1,
    normalNextIndex = 1,
    eliteCurChapter = 0,
    eliteCurSection = 0,
    eliteNextPage = 1,
    eliteNextIndex = 1,
    heroCurChapter = 0,
    heroCurSection = 0,
    heroNextPage = 1,
    heroNextIndex = 1
  }
  local printChapterPage = function(pages)
    for k, page in ipairs(pages) do
      warn("page-------------------------------------------", k)
      for _, node in ipairs(page) do
        warn(string.format("-------------- %d, %d", page.chapterId, node.sectionNum))
      end
    end
  end
end
def.method().OnReset = function(self)
  local dataHeroInfo = self.dataHeroInfo
  dataHeroInfo.normalCurChapter = 0
  dataHeroInfo.normalCurSection = 0
  dataHeroInfo.normalNextPage = 1
  dataHeroInfo.normalNextIndex = 1
  dataHeroInfo.eliteCurChapter = 0
  dataHeroInfo.eliteCurSection = 0
  dataHeroInfo.eliteNextPage = 1
  dataHeroInfo.eliteNextIndex = 1
  dataHeroInfo.heroCurChapter = 0
  dataHeroInfo.heroCurSection = 0
  dataHeroInfo.heroNextPage = 1
  dataHeroInfo.heroNextIndex = 1
end
def.method("number", "=>", "table").getNoramlPage = function(self, page)
  return self.dataNormalPage[page]
end
def.method("=>", "number").getNormalPageCount = function(self)
  return self.maxNormalPage
end
def.method("number", "=>", "table").getElitePage = function(self, page)
  return self.dataElitePage[page]
end
def.method("=>", "number").getElitePageCount = function(self)
  return self.maxElitePage
end
def.method("number", "=>", "table").getHeroPage = function(self, page)
  return self.dataHeroPage[page]
end
def.method("=>", "number").getHeroPageCount = function(self)
  return self.maxHeroPage
end
def.method("=>", "number", "number").getNormalNextSection = function(self)
  local dataHeroInfo = self.dataHeroInfo
  return dataHeroInfo.normalNextPage, dataHeroInfo.normalNextIndex
end
def.method("=>", "number", "number").getEliteNextSection = function(self)
  local dataHeroInfo = self.dataHeroInfo
  return dataHeroInfo.eliteNextPage, dataHeroInfo.eliteNextIndex
end
def.method("=>", "number", "number").getHeroNextSection = function(self)
  local dataHeroInfo = self.dataHeroInfo
  return dataHeroInfo.heroNextPage, dataHeroInfo.heroNextIndex
end
def.method("number", "=>", "number", "number").getProgress = function(self, outPostType)
  local dataHeroInfo = self.dataHeroInfo
  if outPostType == QINGYUNZHI_TYPE.NORMAL then
    return dataHeroInfo.normalCurChapter, dataHeroInfo.normalCurSection
  elseif outPostType == QINGYUNZHI_TYPE.ELITE then
    return dataHeroInfo.eliteCurChapter, dataHeroInfo.eliteCurSection
  elseif outPostType == QINGYUNZHI_TYPE.HERO then
    return dataHeroInfo.heroCurChapter, dataHeroInfo.heroCurSection
  else
    return 0, 0
  end
end
def.method("table", "number", "number", "=>", "number", "number").findNextSection = function(self, pages, chapterNum, sectionNum)
  for p, page in ipairs(pages) do
    if chapterNum == page.chapterId then
      for i, section in ipairs(page) do
        if sectionNum < section.sectionNum then
          return p, i
        end
      end
    elseif chapterNum < page.chapterId then
      return p, 1
    end
  end
  local pageCount = #pages
  local page = pages[pageCount]
  return pageCount, #page
end
def.method("number", "number", "number", "=>", "number", "number").getNextChapterSection = function(self, outPostType, chapterNum, sectionNum)
  local pages
  if outPostType == QINGYUNZHI_TYPE.NORMAL then
    pages = self.dataNormalPage
  elseif outPostType == QINGYUNZHI_TYPE.ELITE then
    pages = self.dataElitePage
  elseif outPostType == QINGYUNZHI_TYPE.HERO then
    pages = self.dataHeroPage
  end
  if pages then
    for p, page in ipairs(pages) do
      if chapterNum == page.chapterId then
        for i, section in ipairs(page) do
          if sectionNum < section.sectionNum then
            return section.chapterNum, section.sectionNum
          end
        end
      elseif chapterNum < page.chapterId then
        local section = page[1]
        return section.chapterNum, section.sectionNum
      end
    end
  end
  return 0, 0
end
def.method("number", "number", "number").syncProgress = function(self, outPostType, chapterNum, sectionNum)
  local dataHeroInfo = self.dataHeroInfo
  if outPostType == QINGYUNZHI_TYPE.NORMAL then
    dataHeroInfo.normalCurChapter = chapterNum
    dataHeroInfo.normalCurSection = sectionNum
    dataHeroInfo.normalNextPage, dataHeroInfo.normalNextIndex = self:findNextSection(self.dataNormalPage, chapterNum, sectionNum)
  elseif outPostType == QINGYUNZHI_TYPE.ELITE then
    dataHeroInfo.eliteCurChapter = chapterNum
    dataHeroInfo.eliteCurSection = sectionNum
    dataHeroInfo.eliteNextPage, dataHeroInfo.eliteNextIndex = self:findNextSection(self.dataElitePage, chapterNum, sectionNum)
  elseif outPostType == QINGYUNZHI_TYPE.HERO then
    dataHeroInfo.heroCurChapter = chapterNum
    dataHeroInfo.heroCurSection = sectionNum
    dataHeroInfo.heroNextPage, dataHeroInfo.heroNextIndex = self:findNextSection(self.dataHeroPage, chapterNum, sectionNum)
  else
    warn("[error]qingyunzhi syncProgress, unknown type!!")
  end
end
def.method("number", "number", "number", "=>", "table").getSectionInfo = function(self, outPostType, chapterNum, sectionNum)
  local dataCfg
  if outPostType == QINGYUNZHI_TYPE.NORMAL then
    dataCfg = self.dataNormalCfg
  elseif outPostType == QINGYUNZHI_TYPE.ELITE then
    dataCfg = self.dataEliteCfg
  elseif outPostType == QINGYUNZHI_TYPE.HERO then
    dataCfg = self.dataHeroCfg
  else
    warn("[error]qingyunzhi getSectionInfo, unknown type!!")
  end
  local dataInfo = {}
  if dataCfg then
    for k, v in pairs(dataCfg) do
      if v.chapterNum == chapterNum and v.sectionNum == sectionNum then
        dataInfo.id = v.id
        dataInfo.chapterNum = v.chapterNum
        dataInfo.chapterPicid = v.chapterPicid
        dataInfo.openLevel = v.openLevel
        dataInfo.reLevelHigh = v.reLevelHigh
        dataInfo.reLevellow = v.reLevellow
        dataInfo.challengeType = v.challengeType
        dataInfo.sectionNum = v.sectionNum
        dataInfo.sectionName = v.sectionName
        dataInfo.sectionPicid = v.sectionPicid
        dataInfo.modelRet = v.modelRet
        dataInfo.reFightValue = v.reFightValue
        dataInfo.roleNumDes = v.roleNumDes
        dataInfo.sectionDes = v.sectionDes
        dataInfo.fightCfgId = v.fightCfgId
        dataInfo.fixAwardId = v.fixAwardId
        dataInfo.npcDlgListVector = v.npcDlgListVector
        return dataInfo
      end
    end
  end
  return dataInfo
end
return QingYunZhiData.Commit()
