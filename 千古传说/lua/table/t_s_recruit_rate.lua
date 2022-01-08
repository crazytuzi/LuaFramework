local mapArray = MEMapArray:new()
mapArray:push({ id = 1, default_value = "10000,5000,50,0,0", change = "0,0,0,0,0", quality = 3, all_give = "24", pay_give = "", max_fail_times = 0, free_perday = 5, cooldown = 600, consume_type = 4, consume_num = 50, consume_goods_id = 30036, consume_goods_num = 1, batch_times = 1})
mapArray:push({ id = 2, default_value = "0,0,10000,500,0", change = "0,0,0,0,0", quality = 4, all_give = "85", pay_give = "", max_fail_times = 0, free_perday = 0, cooldown = 86400, consume_type = 4, consume_num = 300, consume_goods_id = 30037, consume_goods_num = 1, batch_times = 1})
mapArray:push({ id = 3, default_value = "0,10000,8000,100,0", change = "0,0,0,0,0", quality = 4, all_give = "", pay_give = "", max_fail_times = 9, free_perday = 0, cooldown = 0, consume_type = 4, consume_num = 2888, consume_goods_id = 30038, consume_goods_num = 1, batch_times = 10})
mapArray:push({ id = 4, default_value = "0,10000,8000,100,0", change = "", quality = 5, all_give = "", pay_give = "", max_fail_times = 0, free_perday = 0, cooldown = 0, consume_type = 4, consume_num = 400, consume_goods_id = 0, consume_goods_num = 0, batch_times = 0})
return mapArray
