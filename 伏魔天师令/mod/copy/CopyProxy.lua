local CopyProxy = classGc(function(self)
    self.m_bInitialized         = false

    self.m_chapArray={}
    -- 普通
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_NORMAL]={}
    -- 精英
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_HERO]  ={}
    -- 魔王
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_FIEND] ={}

    --精英副本特有数据
    self.m_heroCanPlayTimes     = 0
    self.m_heroCanBuyTimes      = 0
    self.m_heroNowBuyTimes      = 0

    --魔王副本特有数据
    self.m_fiendBuyTimes        = 0


    self.m_currentSectionId     = nil
    self.m_prevchapter          = 0
    self.m_nextchapter          = 0
    self.m_isreward             = 0
    self.m_chaptercopylist      = {}
    self.m_chapterrewardlist    = {}
end)

function CopyProxy.setInitialized( self, bValue)
    self.m_bInitialized = bValue
end
function CopyProxy.getInitialized( self)
    return self.m_bInitialized
end

function CopyProxy.setNormalChapArray(self,_array)
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_NORMAL]=_array
end
function CopyProxy.setHeroChapArray(self,_array)
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_HERO]=_array
end
function CopyProxy.setGemChapArray(self,_array)
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_COPY_GEM]=_array
end
function CopyProxy.setFiendChapArray(self,_array)
    self.m_chapArray[_G.Const.CONST_COPY_TYPE_FIEND]=_array
end
function CopyProxy.getCopyChapData(self,_type)
    return self.m_chapArray[_type]
end


-- *************************************************************************
-- 魔王
-- *************************************************************************
-- 魔王副本已购买次数
function CopyProxy.setfiendBuyTimes( self, _times )
    self.m_fiendBuyTimes = _times or 0
end
function CopyProxy.getfiendBuyTimes( self )
    return self.m_fiendBuyTimes
end



-- *************************************************************************
-- 章节奖励管理表
-- *************************************************************************
function CopyProxy.setChapRewardGetList( self, _list )
    self.m_chapRewardGetList = _list
end
function CopyProxy.getChapRewardGetList( self, _list )
    return self.m_chapRewardGetList or {}
end
function CopyProxy.updateChapRewardGet( self, _chapID, _result )
    print("updateChapRewardGet------->>",_chapID,_result)

    self.m_chapRewardGetList = self.m_chapRewardGetList or {}
    self.m_chapRewardGetList[_chapID] = _result
end



-- *************************************************************************
-- XML 读取
-- *************************************************************************
--副本节点   根据副本Id
function CopyProxy.getCopyNodeByCopyId( self, _copy_id)
    local copy_id = _copy_id
    return _G.Cfg.scene_copy[copy_id]
end

--副本奖励节点   根据副本Id
-- function CopyProxy.getCopyRewardNodeById( self, _copy_id )
--     local copy_id = _copy_id
--     return _G.Cfg.copy_reward[copy_id]
-- end

--章节节点   根据章节Id
function CopyProxy.getScetionNodeById( self, _chapType, _sectionId )
    local sectionId = _sectionId
    local chapType  = _chapType
    print("getScetionNodeById---->>>  ",_chapType,_sectionId)
    if _G.Cfg.copy_chap[chapType] then
        return _G.Cfg.copy_chap[chapType][_sectionId]
    end
    return nil
end


















----------------------------
--副本数据缓存(服务器返回)
----------------------------

--当前选中章节
function CopyProxy.setCurrentSectionId( self, _sectionId )
    self.m_currentSectionId = _sectionId
end
function CopyProxy.getCurrentSectionId( self )
    return self.m_currentSectionId
end
function CopyProxy.getCurrentSectionData( self )
    if self.m_currentSectionId == nil then
        return nil
    end
    for key,sectionData in pairs(self.m_sectionList) do
        if sectionData.chap == self.m_currentSectionId then
            return sectionData
        end
    end
    return nil
end






--当前章节ID   belong_id
function CopyProxy.setCurrentSection( self, _sectionId, _copyType)

    self :setCurrentSectionId( _sectionId )

    --通过XML查找章节名字，前一章ID和后一章ID
    local chapnode = self :getScetionNodeById( _copyType, _sectionId )

    self.m_currentchaptername = chapnode.chap_name
    self.m_prevchapter        = chapnode.per_chap_id
    self.m_nextchapter        = chapnode.next_chap_id
    self.m_nextchapteropenlv  = chapnode.chap_lv
    self.m_chaptercopylist    = chapnode.copy_id
    self.m_chapterrewardlist  = chapnode.chap_reward
    print( self.m_currentchaptername, self.m_prevchapter, self.m_nextchapter)
end


--将要打开tips的副本数据
function CopyProxy.setCurCopyTipsData( self, _copyData )
    self.m_curCopyTipsData = _copyData
end
function CopyProxy.getCurCopyTipsData( self )
    return self.m_curCopyTipsData
end




return CopyProxy





