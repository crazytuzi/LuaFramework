--uiID Ò³Ãæid

i3k_db_task_leadUI =
{
	[1] =
	{
		UIID = 162, openMainUI = true, open = function() i3k_sbean.product_data_sync(6,1) end
	},
	[2] = 
	{
		UIID = 8,openMainUI = false, open = function (itemID) g_i3k_logic:OpenBagUI(itemID) end
	}
};