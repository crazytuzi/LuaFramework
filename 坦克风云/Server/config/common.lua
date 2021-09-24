local function returnCfg(clientPlat)
    local commonCfg = { 
    	-- 属性代号对应的属性名
    	attrNumForAttrStr = {
    		[102]='accuracy',     -- 精准
    		[103]='evade',        -- 闪避
    		[104]='crit',         -- 暴击
    		[105]='anticrit',     -- 免役暴击|韧性|装甲
    		[106]='crit',     
    		[107]='anticrit',
    		[100]='dmg',          -- 伤害|攻击
    		[108]='maxhp',        -- 单体血量
    		[109]='dmg_reduce',   -- 减伤|伤害减免
    		[110]='critDmg',      -- 暴击造成的伤害倍数
    		[111]='decritDmg',    -- 减暴击造成的伤害倍数值
    		[201]='armor',        -- 防护
    		[202]='arp'           -- 穿透
    	},

        attributeStrForCode = {
            decritDmg=111,
            critDmg=110,
            anticrit=105,
            crit=104,
            accuracy=102,
            evade=103,
            crit=106,
            anticrit=107,
            dmg=100,
            maxhp=108,
            attack=100,
            hp=108,
            armor=201,
            arp=202,
            double_hit=203,
        },

        attributeUpForAttrStr = {
            attack='dmg',
            life='maxhp',
            critical='crit',
            decritical='anticrit',
            avoid='evade',
            accurate='accuracy',
            armor='armor',
            arp='arp',
        },

        -- 坦克类型对应的配件科技技能key
        tankTypeToAccessorySkillKey = {
            [1] = "t1",
            [2] = "t2",
            [4] = "t3",
            [8] = "t4",
        },
    }

    local platCfg={ 
    	-- 平台自定义的配制
    } 

    if clientPlat ~= 'def' then         
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end
    end
    
    return commonCfg 
end

return returnCfg
