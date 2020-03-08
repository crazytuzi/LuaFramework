Calendar.Def = {
    OPEN_LEVEL = 20;
}

----------------------------荣誉成就----------------------------
Calendar.GROUP         = 72
Calendar.DATA_MONTH    = 1
Calendar.DIVISION_HOUR = {400, 600, 800, 1000, 1500}
Calendar.JOIN_LV       = 60
Calendar.HONOR_NORMAL  = 0 --普通类型
Calendar.HONOR_MONTH   = 1 --月度类型
Calendar.HONOR_SEASON  = 2 --季度类型
Calendar.tbHonorInfo   = {
    -------------------------------操作方式：1代表递增，0反之---段位信息：参加次数，本服排名，跨服排名，百人战场排名,月度战场，季度战场，年度战场
    Battle         = {nJoinTimesKey = 11, Operation = {1, 0, 0, 0, 0, 0, 0}, Iron = {4, 15, 20, 50, 50,50,50}, Bronze = {8, 8, 12, 30, 15,20,20}, Silver = {16, 4, 6, 15,8,15,15}, Gold = {nil, 2, 3, 6,4,8,8}, Platnum = {nil, nil, 1, 3,2,4,4}},
    ------------------------------------------------------------段位信息：参加次数，登上第几层
    TeamBattle     = {nJoinTimesKey = 21, Operation = {1, 1},       Iron = {2, 4},          Bronze = {4, 5},         Silver = {8, 6},         Gold = {nil, 7},       Platnum = {nil, 8},
                      [Calendar.HONOR_MONTH]  = {[4] = 5, [5] = 6, [6] = 7, [7] = 8},
                      [Calendar.HONOR_SEASON] = {[4] = 6, [5] = 7, [6] = 8, [7] = 8}},
    ------------------------------------------------------------段位信息：参加次数，进入前多少强，进入前60%
    FactionBattle  = {nJoinTimesKey = 31, Operation = {1, 0, 1},    Iron = {2, 16, 1},      Bronze = {3, 16},        Silver = {4, 8},         Gold = {nil, 4},       Platnum = {nil, 1},
                      ["Before60P"] = {[Calendar.HONOR_MONTH] = 16, [Calendar.HONOR_SEASON] = 8},
                      [Calendar.HONOR_MONTH]  = {[16] = 8, [8] = 4, [4] = 1, [2] = 1},
                      [Calendar.HONOR_SEASON] = {[16] = 4, [8] = 1, [4] = 1, [2] = 1}},
    ------------------------------------------------------------段位信息：参加次数，评价
    InDifferBattle = {nJoinTimesKey = 41, Operation = {1, 1},       Iron = {2, 2},          Bronze = {4, 3},         Silver = {8, 4},         Gold = {nil, 5},       Platnum = {nil, 6},
                      [Calendar.HONOR_MONTH]  = {[2] = 3, [3] = 4, [4] = 5, [5] = 6},
                      [Calendar.HONOR_SEASON] = {[2] = 4, [3] = 5, [4] = 6, [5] = 6}},
    ------------------------------------------------------------段位信息：参加次数，排名
    HuaShanLunJian = {nJoinTimesKey = 51, Operation = {1, 0},       Iron = {8, 256},        Bronze = {16, 128},      Silver = {32, 64},       Gold = {nil, 32},      Platnum = {nil, 8}},
    ------------------------------------------------------------段位信息：参加次数，获胜多少轮
    QunYingHui     = {nJoinTimesKey = 61, Operation = {1, 1},       Iron = {2, 2},          Bronze = {nil, 6},       Silver = {nil, 8},       Gold = {nil, 10},      Platnum = {nil, 12}},
}

--[[
Calendar.tbDivisionAward = {
    10460,--10460	武林荣誉黑铁宝箱
    10461,--10461	武林荣誉青铜宝箱
    10462,--10462	武林荣誉白银宝箱
    10463,--10463	武林荣誉黄金宝箱
    10464,--10464	武林荣誉白金宝箱
}
]]

Calendar.tbDivisionAward = {
    {{"Energy", 5000}},
    {{"Energy", 6000}, {"Item", 4462, 1}},
    {{"Energy", 6000}, {"Item", 4816, 1}},
    {{"Energy", 9000}, {"Item", 4816, 1}},
    {{"Energy", 6000}, {"Item", 4817, 1}},
}

Calendar.tbDivisionKey = {"Iron", "Bronze", "Silver", "Gold", "Platnum"}
--对应活动荣誉是否关闭，列表中为关闭
Calendar.tbUnopenHonor = {}
function Calendar:GetDivision(pPlayer, szKey, nLastDivision)
	local tbInfo = self.tbHonorInfo[szKey]
	local tbData = {}
	for i = 1, #tbInfo.Operation do
		table.insert(tbData, pPlayer.GetUserValue(self.GROUP, tbInfo.nJoinTimesKey + i - 1))
	end
	for nDivision = #self.tbDivisionKey, 1, -1 do
		if nLastDivision and nDivision <= nLastDivision then
			return nLastDivision
		end
		local tbDivision = tbInfo[self.tbDivisionKey[nDivision]]
		for nIdx = 1, #tbDivision do
			local nData    = tbData[nIdx]
			local nRequire = tbDivision[nIdx]
			if nRequire and nData > 0 then
				local bComplete = (tbInfo.Operation[nIdx] > 0 and nData >= nRequire) or (tbInfo.Operation[nIdx] == 0 and nData <= nRequire)
				if bComplete then
					return nDivision
				end
			end
		end

	end
	return 0
end

Calendar.tbMsgFormatInfo = {"进入前%d名", "获得第%d名", "登上第%d层", "获得卓越以上评价", "获得最佳以上评价", "单场获胜%d轮", "单场%d轮全胜"}
Calendar.tbActMsgInfo = {
    Battle         = {nRankBitId = 1, tbName = {"宋金战场", "跨服战场", "百人战场"}, Gold = {1, 1, 1}, Platnum = {nil, 2, 1}},
    TeamBattle     = {nRankBitId = 2, tbName = {"通天塔"},                           Gold = {3},       Platnum = {3}},
    FactionBattle  = {nRankBitId = 3, tbName = {"门派竞技"},                         Gold = {1},       Platnum = {2}},
    InDifferBattle = {nRankBitId = 4, tbName = {"心魔幻境"},                         Gold = {4},       Platnum = {5}},
    HuaShanLunJian = {nRankBitId = 5, tbName = {"华山论剑"},                         Gold = {1},       Platnum = {1}},
    QunYingHui     = {nRankBitId = 6, tbName = {"群英会"},                           Gold = {6},       Platnum = {7}},
}
Calendar.tbDivisionName     = {"黑铁", "青铜", "白银", "黄金", "白金"}

function Calendar:Act2Number(param)
    if type(param) == "number" then
        local tbAct = {}
        for szAct, tbInfo in pairs(self.tbActMsgInfo) do
            if KLib.GetBit(param, tbInfo.nRankBitId) == 1 then
                table.insert(tbAct, szAct)
            end
        end
        return tbAct
    elseif type(param) == "table" then
        local nNumber = 0
        for szAct in pairs(param) do
            if self.tbActMsgInfo[szAct] then
                nNumber = KLib.SetBit(nNumber, self.tbActMsgInfo[szAct].nRankBitId, 1)
            end
        end
        return nNumber
    end
end