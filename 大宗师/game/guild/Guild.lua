 --[[--
 --
 -- @authors shan 
 -- @date    2014-12-23 13:50:32
 -- @version 
 --
 --]]

local Guild = class("Guild")


function Guild:ctor(param)

	self:init(param)

	-- property
	self.getName = function (  )
		return self.m_name
	end

	self.getLv = function (  )
		return self.m_lv
	end
end

--- 
-- 对帮派初始化
--
function Guild:init( param )
		-- base info
	self.m_id                = param.id  			  -- /**帮派id*/
	self.m_name              = param.name             -- /**帮派名称*/
	self.m_level             = param.level            -- /**帮派等级*/
	self.m_rank              = param.rank             -- /**帮派排名*/
	self.m_roleMaxNum        = param.roleNum       	  -- /**帮派人数上线*/
	self.m_createTime        = param.createTime       -- /**帮派创建时间*/
	self.m_sumAttack         = param.sumAttack        -- /**帮派攻击力*/
	self.m_bossId            = param.bossId           -- /**帮主id*/
	self.m_unionIndes        = param.unionIndes       -- /**帮派公告*/
	self.m_unionOutdes       = param.unionOutdes      -- /**帮派宣言*/
	self.m_totalUnionMoney   = param.totalUnionMoney  -- /**帮派总资金*/
	self.m_currentUnionMoney = param.currentUnionMoney-- /**帮派当前资金*/
	self.m_workshoplevel     = param.workShopLevel    -- /**工坊建筑等级*/
	self.m_barbecueTime      = param.barbecueTime     -- /**烧烤大会开启时间*/
	self.m_openBarRole       = param.openBarRole      -- /**烧烤大会开启人*/
	self.m_shoplevel         = param.shopLevel        -- /**帮派商店等级*/
	self.m_coverTime         = param.coverTime        -- /**帮派自荐时间**/
	self.m_freeworknum       = param.freeworkNum      -- /**免费生产次数*/
	self.m_buyworkNum        = param.buyworkNum       -- /**购买生产次数*/
	self.m_starworktime      = param.starworktime     -- /**开始生产时间*/
	self.m_worktype          = param.worktype         -- /**生产类型0侠魂1银币*/
	self.m_overtimeflag      = param.overtimeflag     -- /**是否加班生产0是1否*/
	self.m_buyNum            = param.buyNum           -- /**道具购买次数*/
	self.m_selfMoney 		 = param.selfMoney 		  -- 个人贡献 
	self.m_nowRoleNum 		 = param.nowRoleNum 	  -- 帮派当前人数 
	self.m_greenDragonTempleLevel = param.greenDragonTempleLevel  -- 青龙堂等级 
	self.m_leaderName   	 = param.leaderName 	  -- 帮主名称 
	self.m_jopType 			 = param.jopType 		  -- 职务 
	self.m_fubenLevel		 = param.FBLevel or 0 	  -- 帮派副本等级  


end


function Guild:updateData(param)
	self.m_selfMoney = param.selfMoney or self.m_selfMoney 
	self.m_currentUnionMoney = param.currentUnionMoney or self.m_currentUnionMoney 
	self.m_workshoplevel = param.workshopLevel or self.m_workshoplevel 
	self.m_greenDragonTempleLevel = param.qinglongLevel or self.m_greenDragonTempleLevel 
	self.m_fubenLevel = param.fubenLevel or self.m_fubenLevel 

end 


return Guild