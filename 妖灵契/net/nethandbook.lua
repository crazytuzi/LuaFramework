module(..., package.seeall)

--GS2C--

function GS2CLoginBookList(pbdata)
	local book_list = pbdata.book_list
	local red_points = pbdata.red_points --红点
	--todo
	g_MapBookCtrl:InitBookList(table.copy(book_list))
	g_MapBookCtrl:InitRedPoint(red_points)
end

function GS2CBookInfoChange(pbdata)
	local book_info = pbdata.book_info
	--todo
	g_MapBookCtrl:UpdateBook(book_info)
end

function GS2CPartnerProgress(pbdata)
	local progress = pbdata.progress
	--todo
	g_MapBookCtrl:UpdatePartnerProgress(progress)
end

function GS2CPartnerEquipProgress(pbdata)
	local progress = pbdata.progress
	--todo
	g_MapBookCtrl:UpdateEquipProgress(progress)
end

function GS2CHandBookRedPoint(pbdata)
	local red_point = pbdata.red_point
	--todo
	g_MapBookCtrl:UpdateRedPoint(red_point)
end


--C2GS--

function C2GSUnlockBook(book_id)
	local t = {
		book_id = book_id,
	}
	g_NetCtrl:Send("handbook", "C2GSUnlockBook", t)
end

function C2GSUnlockChapter(chapter_id)
	local t = {
		chapter_id = chapter_id,
	}
	g_NetCtrl:Send("handbook", "C2GSUnlockChapter", t)
end

function C2GSEnterName(book_id)
	local t = {
		book_id = book_id,
	}
	g_NetCtrl:Send("handbook", "C2GSEnterName", t)
end

function C2GSRepairDraw(book_id)
	local t = {
		book_id = book_id,
	}
	g_NetCtrl:Send("handbook", "C2GSRepairDraw", t)
end

function C2GSReadChapter(chapter_id)
	local t = {
		chapter_id = chapter_id,
	}
	g_NetCtrl:Send("handbook", "C2GSReadChapter", t)
end

function C2GSCloseHandBookUI(book_type)
	local t = {
		book_type = book_type,
	}
	g_NetCtrl:Send("handbook", "C2GSCloseHandBookUI", t)
end

function C2GSOpenBookChapter(book_id)
	local t = {
		book_id = book_id,
	}
	g_NetCtrl:Send("handbook", "C2GSOpenBookChapter", t)
end

