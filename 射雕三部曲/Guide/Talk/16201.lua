
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 25, text = "@1",
            maxWidth = 500,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =1.5,
        },},
    {delay = {time = 0.5,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
        },},
    },


    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },








jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },



jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},},



qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },





    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

     {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -101,
            file  = "bj.png",
        },
    },


    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },
    {
        model = {
            tag   = "map0",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1020, 100),
            order = -99,
            file  = "guiyun.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(900, 100),
            order = -99,
            file  = "guiyun.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },


    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(2820, 100),
            order = -99,
            file  = "guiyun.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
    },






    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

	{
        music = {file = "loginmusic.mp3",},
    },


     {
         load = {tmpl = "zm",
             params = {TR("太湖，归云山庄"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("郭靖邀请各路英雄豪杰，"),"850"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("推举武林盟主，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("共商抗蒙大业，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("却来了几个不速之客……"),"700"},},
     },









    {
        load = {tmpl = "mod22",
            params = {"zcong","hero_zhucong","-100","200","0.12","clip_1","33"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lyjiao","hero_luyoujiao","-150","220","0.12","clip_1","32"},},
    },
    {
       delay = {time = 0.15,},
    },
    {
        load = {tmpl = "mod22",
            params = {"ydtian","hero_yangdingtian","-200","210","0.12","clip_1","30"},},
    },



    {
        load = {tmpl = "mod22",
            params = {"hqniu","hero_huqingniu","70","200","0.12","clip_1","31"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"jxfu","hero_jixiaofu","160","210","0.12","clip_1","32"},},
    },
    {
       delay = {time = 0.15,},
    },
    {
        load = {tmpl = "mod22",
            params = {"gxtian","hero_guoxiaotian","220","200","0.12","clip_1","33"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"zdian","hero_zhoudian","-50","240","0.12","clip_1","21"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"yywang","hero_yinyewang","40","240","0.12","clip_1","22"},},
    },


    {
        load = {tmpl = "mod22",
            params = {"sqshu","hero_songqingshu","-50","120","0.12","clip_1","41"},},
    },
    {
       delay = {time = 0.15,},
    },
    {
        load = {tmpl = "mod22",
            params = {"wstong","hero_wusantong","40","120","0.12","clip_1","42"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"zzliu","hero_zhuziliu","190","120","0.12","clip_1","43"},},
    },
    {
        load = {tmpl = "mod22",
            params = {"qlfeng","hero_qulingfeng","-140","150","0.12","clip_1","40"},},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0","0.7","-150","-280"},},
     },

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(500,120),    order     = 50,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(640,200),    order     = 48,
            file = "hero_huangrong",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(690,100),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "gfu",     type  = DEF.FIGURE,
            pos= cc.p(720,180),    order     = 45,
            file = "hero_guofu",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.7,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {   model = {
            tag  = "wdru",     type  = DEF.FIGURE,
            pos= cc.p(830,160),    order     = 44,
            file = "hero_wudunru",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
    {   model = {
            tag  = "wxwen",     type  = DEF.FIGURE,
            pos= cc.p(780,220),    order     = 43,
            file = "hero_wuxiuwen",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},



    {delay = {time = 0.9,},},

    {remove = { model = {"900", "850", "800","750", "700", }, },},


    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.4,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","1","-260","-300"},},
     },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk1",
             params = {"gj",TR("各位，今天各路英雄云集，郭某倍感荣幸，如今蒙古南侵，形式危急！"),"1282.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"gj",TR("今日召开武林大会，便是要与诸位商议，推举一位武林盟主，领导群雄，抗敌救国！"),"1283.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"zzl","zzl.png",TR("朱子柳")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zzl",TR("在下认为，当今世上，论武艺论品德，这武林盟主非洪七公洪老前辈莫属！"),"1284.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"zzl","gj"},},
    },







    {   model = {
            tag  = "hdu",     type  = DEF.FIGURE,
            pos= cc.p(-500,0),    order     = 70,
            file = "hero_huodu",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(-520,-70),    order     = 70,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "deba",     type  = DEF.FIGURE,
            pos= cc.p(-560,-150),    order     = 70,
            file = "hero_daerba",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.7,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","0","-300"},},
     },






    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {action = {tag  = "hdu",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-100,0),
                                 control={cc.p(-500,0),cc.p(-200,400),}
    },},},
    },},},
    {
       delay = {time = 0.2,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "jlfwang",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-120,-50),
                                 control={cc.p(-520,-70),cc.p(-200,400),}
    },},},
    },},},
    {
       delay = {time = 0.08,},
    },
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "deba",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-220,-60),
                                 control={cc.p(-560,-90),cc.p(-300,300),}
    },},},
    },},},



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-200","-300"},},
     },



     {
         load = {tmpl = "move1",
             params = {"hd","hd.png",TR("霍都")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hd",TR("哈哈哈！我看这武林盟主不如由我们蒙古国第一护国法师——金轮法王来担任吧！"),"1285.mp3"},},
     },


     {
         load = {tmpl = "move2",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("霍都？几位远道而来，不知有何赐教？"),"1286.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"hd",TR("所谓盛会难逢，既然天下英雄有意推举武林盟主，家师金轮法王实在是当之无愧！"),"1287.mp3"},},
     },


    {
        load = {tmpl = "out2",
            params = {"gj"},},
    },





    {remove = { model = {"zzliu", }, },},
    {
        load = {tmpl = "mod21",
            params = {"zzliu","hero_zhuziliu","190","120","0.12","clip_1","43"},},
    },



     {
         load = {tmpl = "move2",
             params = {"zzl","zzl.png",TR("朱子柳")},},
     },
     {
         load = {tmpl = "talk",
             params = {"zzl",TR("哼！我们已经推举洪七公老前辈为武林盟主，你们还是请回吧！"),"1288.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"hd",TR("洪七公？洪七公又算得了什么，有本事便出来与家师一决高下，看看该谁来做这个武林盟主！"),"1289.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"zzl"},},
    },

     {
         load = {tmpl = "move2",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("洪七公他老人家，并未前来，今日就由我这个弟子代替他老人家会会你这个蒙古国师吧！"),"1290.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"hd"},},
    },


     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("好！今天就让你见识见识我的龙象般若功！"),"1291.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"jlfw","gj"},},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","2","0","-1200"},},
     },

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-500,600),    order     = 70,
            file = "hero_ouyangke",    animation = "win",
            scale = 0.08,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.1,to = 0.08,},},
    {bezier = {time = 0.2,to = cc.p(20,600),
                                 control={cc.p(-500,400),cc.p(-200,900),}
    },},},
    },},},


     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("郭靖！黄蓉！你们让我想得好辛苦啊！"),"1292.mp3"},},
     },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-250","-300"},},
     },

     {
         load = {tmpl = "move2",
             params = {"hr","hr.png",TR("黄蓉")},},
     },
     {
         load = {tmpl = "talk",
             params = {"hr",TR("欧阳克，怎么可能，你不是已经……"),"1293.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("哈哈哈！黄蓉！任你奸猾如鬼，今日我也要让你们命丧于此！"),"1294.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"oyk","hr"},},
    },

       {remove = { model = {"text-board", }, },},


    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(500,120),    order     = 50,
            file = "hero_guojing",    animation = "zou",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "gjing",sync = true,what = {move = {
                   time = 0.6,by = cc.p(-100,180),},},},},

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(400,300),    order     = 50,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},



    {
        sound = {file = "hero_ouyangke_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "oyke1",     type  = DEF.FIGURE,
            pos= cc.p(20,600),    order     = 70,
            file = "hero_ouyangke",    animation = "pugong",
            scale = 0.08,   parent = "clip_1", speed = 1.5,opacity=165,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
        sound = {file = "hero_guojing_pugong.mp3",sync=false,},
    },


    {   model = {
            tag  = "gjing1",     type  = DEF.FIGURE,
            pos= cc.p(400,300),    order     = 50,
            file = "hero_guojing",    animation = "pugong",
            scale = 0.12,   parent = "clip_1", speed = 1.25,opacity=155,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.3,},
    },

    {
        sound = {file = "skill_lingshequan.mp3",sync=false,},
    },

    {   model = {
            tag  = "long1",     type  = DEF.FIGURE,
            pos= cc.p(20,640),    order     = 80,
            file = "effect_waigong_lingshequan",    animation = "animation",
            scale = 0.3,    parent = "clip_1", opacity=155,
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},







    {action = {tag  = "long1",sync = false,what ={ spawn={{scale= {time = 0.88,to  =0.4,},},
    {bezier = {time = 0.8,to = cc.p(360,390),
                                 control={cc.p(20,600),cc.p(190,440),}
    },},},
    },},},
    {action = {tag  = "gjing1",sync = false,what ={ spawn={{move= {time = 0.8,by = cc.p(-40,20),},},
    {rotate = {to = cc.vec3(0, 180, 30),time = 0.8,},},},},},},
    {
       delay = {time = 0.3,},
    },
    {
        sound = {file = "skill_lingshequan.mp3",sync=false,},
    },
    {   model = {
            tag  = "long2",     type  = DEF.FIGURE,
            pos= cc.p(20,640),    order     = 80,
            file = "effect_waigong_lingshequan",    animation = "animation",
            scale = 0.3,    parent = "clip_1", opacity=125,
            loop = true,   endRlease = true,  speed=0.8, rotation3D=cc.vec3(0,0,0),
        },},


    {action = {tag  = "long2",sync = false,what ={ spawn={{scale= {time = 0.8,to  =0.4,},},
    {bezier = {time = 0.8,to = cc.p(360,390),
                                 control={cc.p(20,600),cc.p(190,440),}
    },},},
    },},},





    {action = {tag  = "oyke1",sync = false,what ={ spawn={{scale= {time = 0.9,to = 0.12,},},
    {bezier = {time = 0.9,to = cc.p(360,320),
                                 control={cc.p(20,600),cc.p(190,460),}
    },},},
    },},},

    {
       delay = {time = 0.2,},
    },

    {
       delay = {time = 0.3,},
    },



    {remove = { model = {"long1", }, },},

    {
       delay = {time = 0.3,},
    },

    {remove = { model = {"long2", }, },},




    {
       delay = {time = 0.3,},
    },

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(400,300),    order     = 50,
            file = "hero_guojing",    animation = "aida",
            scale = 0.12,   parent = "clip_1", speed = 1.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "gjing",sync = false,what = {move = {
                   time = 0.2,by = cc.p(100,-50),},},},},


    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(20,600),    order     = 70,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.08,   parent = "clip_1", speed = 1.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.2,by = cc.p(-20,0),},},},},


    {remove = { model = {"oyke1", }, },},

    {
       delay = {time = 0.2,},
    },

    {remove = { model = {"gjing1", }, },},






    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(500,250),    order     = 50,
            file = "hero_guojing",    animation = "yun",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,600),    order     = 70,
            file = "hero_ouyangke",    animation = "yun",
            scale = 0.08,   parent = "clip_1", speed = 0.7,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(640,200),    order     = 78,
            file = "hero_huangrong",    animation = "zou",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "hrong",sync = true,what = {move = {
                   time = 0.3,by = cc.p(-110,30),},},},},
    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(530,230),    order     = 78,
            file = "hero_huangrong",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},



    {
       delay = {time = 0.2,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },
     {
         load = {tmpl = "move2",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("好邪门的功夫！"),"1295.mp3"},},
     },

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(500,250),    order     = 50,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},






    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,600),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.08,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},







     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("郭靖，你明明又呆又傻，为什么？为什么武功会如此厉害！"),"1297.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"oyk","gj"},},
    },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-50","-250"},},
     },

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,600),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.08,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

     {
         load = {tmpl = "move2",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },

     {
         load = {tmpl = "talk",
             params = {"oyk",TR("大和尚！你我联手，杀了郭靖，你便是这天下的武林盟主！"),"1298.mp3"},},
     },


     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("好主意！"),"1299.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"jlfw","oyk"},},
    },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-250","-250"},},
     },


    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "jlfwang",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(280,-50),
                                 control={cc.p(-120,-50),cc.p(80,300),}
    },},},
    },},},

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,600),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.08,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},



    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "move2",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("卑鄙小人！"),"1300.mp3"},},
     },


    {
        load = {tmpl = "out2",
            params = {"yg"},},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 0.1,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(450,-50),
                                 control={cc.p(690,100),cc.p(550,300),}
    },},},
    },},},


     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("乳臭未干的小屁孩，也想螳臂挡车！"),"1301.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"jlfw"},},
    },



     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },

	{
        music = {file = "backgroundmusic1.mp3",},
    },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿！"),"1302.mp3"},},
     },







    {
        load = {tmpl = "out2",
            params = {"xln"},},
    },




    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(1200,-50),    order     = 50,
            file = "hero_xiaolongnv",    animation = "putongzhanzi",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","1.5","-1800","-150"},},
     },

    {remove = { model = {"yguo", "gfu","wdru","wxwen", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(450,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {   model = {
            tag  = "gfu",     type  = DEF.FIGURE,
            pos= cc.p(620,180),    order     = 45,
            file = "hero_guofu",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.7,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "wdru",     type  = DEF.FIGURE,
            pos= cc.p(730,160),    order     = 44,
            file = "hero_wudunru",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
    {   model = {
            tag  = "wxwen",     type  = DEF.FIGURE,
            pos= cc.p(680,220),    order     = 43,
            file = "hero_wuxiuwen",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
       delay = {time = 1.2,},
    },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.4","1.5","-750","-100"},},
     },

     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑！"),"1303.mp3"},},
     },



    {
        load = {tmpl = "out1",
            params = {"yg"},},
    },

       {remove = { model = {"text-board", }, },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.4","1.5","-1600","-100"},},
     },

    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(450,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "yguo",sync = false,what = {move = {
                   time = 2,by = cc.p(400,0),},},},},


     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.1","1","-900","0"},},
     },
    {
       delay = {time = 0.4,},
    },

    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(1200,-50),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "xlnv",sync = true,what = {move = {
                   time = 1.6,by = cc.p(-300,0),},},},},






    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(850,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(900,-50),    order     = 50,
            file = "hero_xiaolongnv",    animation = "shunvzhanzi",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },




     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },
     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿！"),"1304.mp3"},},
     },
     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑，你到哪里去，过儿找你找得好辛苦！"),"1305.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("你真的是过儿？姑姑不是在做梦吧！"),"1306.mp3"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"yg",TR("不是，姑姑，你不是在做梦！"),"1307.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"yg",TR("姑姑，你别在生过儿的气啦！你别在丢下过儿啦！"),"1308.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("我不知道！"),"1309.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("过儿不管！从今以后，就算是姑姑去到天涯海角，过儿都不会再离开你了！"),"1310.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿！"),"1311.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"yg","xln"},},
    },



    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(400,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","0.8","-500","-100"},},
     },



	{
        music = {file = "battle1.mp3",},
    },



     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("你们要叙旧，就到一边去，别妨碍我！"),"1312.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"jlfw"},},
    },

     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑，这个大和尚想趁人之危害我郭伯伯，我们先拦住他！"),"1313.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },
     {
         load = {tmpl = "talk",
             params = {"xln",TR("好的，过儿！"),"1314.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"yg","xln"},},
    },









    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(850,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(850,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(850,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(900,-50),    order     = 50,
            file = "hero_xiaolongnv",    animation = "zou",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
        {action = { tag  = "xlnv",sync = true,what = {move = {
                   time = 0.6,by = cc.p(-50,-100),},},},},

    {remove = { model = {"xlnv", }, },},
    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(850,-150),    order     = 50,
            file = "hero_xiaolongnv",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},



     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("既然你们不知好歹，那你们就一起死吧！"),"1315.mp3"},},
     },


    {
        load = {tmpl = "out1",
            params = {"jlfw"},},
    },

       {remove = { model = {"text-board", }, },},




    {
        sound = {file = "hero_jinlunfawang_nuji.mp3",sync=false,},
    },

    -- {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang1",     type  = DEF.FIGURE,
            pos= cc.p(400,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "nuji",
            scale = 0.12,   parent = "clip_1", speed = 1, opacity = 125,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.3,},
    },

    {
        model = {
            tag = "jlfwang1",
            speed = 0,
        },
    },

    {   model = {
            tag  = "jlfwang2",     type  = DEF.FIGURE,
            pos= cc.p(350,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "nuji",
            scale = 0.12,   parent = "clip_1", speed = 0.4, opacity = 85,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
    {
       delay = {time = 0.3,},
    },
    {   model = {
            tag  = "jlfwang3",     type  = DEF.FIGURE,
            pos= cc.p(450,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "nuji",
            scale = 0.12,   parent = "clip_1", speed = 0.5, opacity = 155,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.3,},
    },









    {
        sound = {file = "joint_12301s.mp3",sync=false,},
    },

     {
        model = {
            tag   = "mapbj1",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = 80,
            file  = "bj.png",
        },
    },



    {   model = {
            tag  = "heimu",     type  = DEF.FIGURE,
            pos= cc.p(320,560),    order     = 81,
            file = "effect_nujifenwei",    animation = "animation",
            scale = 0.96,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},



     {
        model = {
            tag   = "yguo1",
            type  = DEF.PIC,
            scale = 0.15,
            pos   = cc.p(0, 780),
            order = 82,
            file  = "yglh.png",rotation3D=cc.vec3(0,0,0),
        },
    },


    {action = {tag  = "yguo1",sync = false,what ={ spawn={{scale= {time = 0.9,to = 1.2,},},
    {bezier = {time = 0.9,to = cc.p(280,640),
                                 control={cc.p(0,580),cc.p(240,180),}
    },},},
    },},},


     {
        model = {
            tag   = "xlnv2",
            type  = DEF.PIC,
            scale = 0.15,
            pos   = cc.p(640, 780),
            order = 85,
            file  = "xlnlh.png",rotation3D=cc.vec3(0,180,0),
        },
    },



    {action = {tag  = "xlnv2",sync = true,what ={ spawn={{scale= {time = 0.9,to = 1.2,},},
    {bezier = {time = 0.9,to = cc.p(330,500),
                                 control={cc.p(0,580),cc.p(240,180),}
    },},},
    },},},

    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(850,-50),    order     = 50,
            file = "hero_yangguo_hei",    animation = "nuji",
            scale = 0.12,   parent = "clip_1", speed = 1.2,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


    {
        delay = {time = 1,},
    },

    {
        sound = {file = "hero_yangguo_nuji.mp3",sync=false,},
    },

    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(850,-150),    order     = 85,
            file = "hero_xiaolongnv",    animation = "nuji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},


        {action = { tag  = "hdu",sync = false,what = {move = {
                   time = 0.01,to = cc.p(-250,250),},},},},
        {action = { tag  = "deba",sync = false,what = {move = {
                   time = 0.01,to = cc.p(-320,300),},},},},

    {remove = { model = {"jlfwang1","jlfwang2","jlfwang3", }, },},
    {
        delay = {time = 0.2,},
    },
    {remove = { model = {"xlnv2", "yguo1", "heimu","mapbj1",}, },},



     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1","0.8","-300","-200"},},
     },


    {
        sound = {file = "hero_xiaolongnv_nuji.mp3",sync=false,},
    },


    {action = {tag  = "xlnv",sync = false,what ={ spawn={{scale= {time = 1,to = 0.12,},},
    {bezier = {time = 1,to = cc.p(480,-50),
                                 control={cc.p(850,-150),cc.p(660,200),}
    },},},
    },},},

    {
        delay = {time = 0.6,},
    },

    {action = {tag  = "yguo",sync = false,what ={ spawn={{scale= {time = 1,to = 0.12,},},
    {bezier = {time = 1,to = cc.p(580,-50),
                                 control={cc.p(850,-50),cc.p(660,250),}
    },},},
    },},},


    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(400,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "aida",
            scale = 0.12,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "jlfwang",sync = true,what = {move = {
                   time = 0.4,by = cc.p(-150,0),},},},},


    {remove = { model = {"yguo", }, },},
    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(580,-50),    order     = 80,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "xlnv",sync = false,what = {move = {
                   time = 0.4,by = cc.p(-150,0),},},},},

        {action = { tag  = "jlfwang",sync = true,what = {move = {
                   time = 0.4,by = cc.p(-150,0),},},},},

    {
       delay = {time = 0.8,},
    },

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(100,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"xlnv", }, },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(330,-150),    order     = 85,
            file = "hero_xiaolongnv",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"jlfw","jlfw.png",TR("金轮法王")},},
     },
     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("你们这是什么剑法！"),"1321.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"yg","yg.png",TR("杨过")},},
     },
     {
         load = {tmpl = "talk",
             params = {"yg",TR("这是我们中原最出名的刺驴剑法，专治你们这些不守清规的秃驴！"),"1322.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"jlfw",TR("哼！今天老衲不和你们斗，我们后会有期！"),"1323.mp3"},},
     },


    {
        load = {tmpl = "out3",
            params = {"jlfw","yg"},},
    },

    {remove = { model = {"jlfwang", }, },},
    {   model = {
            tag  = "jlfwang",     type  = DEF.FIGURE,
            pos= cc.p(100,-50),    order     = 70,
            file = "hero_jinlunfawang",    animation = "daiji",
            scale = 0.12,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
    {action = {tag  = "jlfwang",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-400,-50),
                                 control={cc.p(100,-50),cc.p(-200,350),}
    },},},
    },},},



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.8","-100","-300"},},
     },


     {
         load = {tmpl = "move1",
             params = {"oyk","oyk.png",TR("欧阳克")},},
     },
     {
         load = {tmpl = "talk",
             params = {"oyk",TR("郭靖，黄蓉，你们给我等着，我一定要将你们抽筋剥皮！以泄我心头之愤！"),"1324.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"oyk"},},
    },

    {remove = { model = {"oyke", }, },},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(0,600),    order     = 70,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.08,   parent = "clip_1", speed = 0.5,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},



    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "oyke",sync = true,what ={ spawn={{scale= {time = 0.2,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-400,600),
                                 control={cc.p(0,600),cc.p(-200,1000),}
    },},},
    },},},






    {
       delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
