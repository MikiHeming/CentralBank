script_name('Bank-Helper')
script_author('Cosmo')
script_version('20.0')

require "moonloader"
require "sampfuncs"
local dlstatus = require "moonloader".download_status
local bse, se               = pcall(require, "lib.samp.events")
local bInicfg, inicfg       = pcall(require, "inicfg")
local bImgui, imgui         = pcall(require, "imgui")
local bEncoding, encoding   = pcall(require, "encoding")
local bMemory, memory       = pcall(require, "memory")

local mc, sc, wc = '{2090FF}', '{00AAFF}', '{FFFFFF}'
local mcx = 0x2090FF

local u8 = encoding.UTF8
encoding.default = 'CP1251'
local noErrorDialog = false
local tag = string.format("[ Central Bank ] %s", wc)
local id_kassa = 0
local distBetweenKassa = 0
local temp_prem = nil
local lections = {}
local status_button_gov = false
local jsn_upd = "https://gitlab.com/snippets/1978930/raw"
local lect_path = getWorkingDirectory() .. '\\BHelper\\Lections.json'
local calc_font = renderCreateFont('Calibri', 12, 1)

local cfg = inicfg.load({
	main = 
	{
		rank = 1,
		dateuprank = os.time(),
		sex = 1,
		encode_ustav = true,
		autoF8 = true,
		upWithRp = true,
		LectDelay = 5,
		MsgDelay = 2.5,
		rpbat = false,
		rpbat_true = "/me {sex:????|?????} ??????? ? ????? ???? ? ?????? ????",
		rpbat_false = "/me {sex:???????|????????} ??????? ?? ????" , 
		colorRchat = 4282626093,
		colorDchat = 4294940723,
		colorCosmo = 4288216832,
		defaultColor = -1,
		black_theme = true,
		forma_post = '/r ???????????: {my_name} | ????: [????] | ?????????: ??????????',
		forma_lect = '/r ??????????! ???? ????????? ? ??????????, ????? ??????! ?? ??????? - ???????!',
		forma_tr = '/r ??????????! ?????? ????? ??????????! ???? ?? ?????! ?? ??????? - ???????!',
		accent_status = false,
		accent = '[??????? ????]',
		glass_light = 1.0,
		glass_light_child = 1.0,
		infoupdate = false,
		loginupdate = true,
		KipX = select(1, getScreenResolution()) - 250,
		KipY = select(2, getScreenResolution()) / 2, 
		ki_stat = true,
		timeF9 = true, 
		expelReason = '?.?.?',
		chat_calc = true,
	},
	kassa =
	{
		dep = tonumber(0),
		card = tonumber(0),
		credit = tonumber(0),
		recard = tonumber(0)
	},
	Chat = {
		expel = true,
		shtrafs = true,
		incazna = true,
		invite = true,
		uval = true
	},
	nameRank = {
		'????????', 
		'??????? ????????', 
		'????????? ??????', 
		'??.????????? ?????', 
		'???.?????? ??????????', 
		'???.?????? ??????????', 
		'????????', 
		'???.?????????', 
		'???????? ?????', 
		'??????? ????????'
	},
	govstr = {
		'[??????????? ????] ????????? ?????? ?????!',
		'[??????????? ????] ?? ?????? ?????? ???????? ???? ???????? ?????? ? ??????????? ????!',
		'[??????????? ????] ??? ????? ??????? ? ???? ?????! ???? ???!'
	},
	govdep = {
		'[????] - [????] ??????? ???.?????, ??????? ?? ??????????',
		'[????] - [????] ?????????? ???.?????'
	},
	blacklist = {},
	Binds_Name = {},
	Binds_Action = {},
	Binds_Deleay = {}
}, "Bank_Config")

local bank              = imgui.ImBool(false)
local int_bank          = imgui.ImBool(false)
local type_window       = imgui.ImInt(1)
local TypeAction        = imgui.ImInt(1)
local question          = imgui.ImInt(1)
local giverank          = imgui.ImInt(1)
local text_binder       = imgui.ImBuffer(65536) 
local binder_name       = imgui.ImBuffer(40) 
local binder_delay      = imgui.ImInt(2500)
local play_current_bind = imgui.ImBool(false)
local ustav_window      = imgui.ImBool(false)
local search_ustav      = imgui.ImBuffer(256)
local go_credit         = imgui.ImBool(false)
local credit_sum        = imgui.ImInt(5000)
local mGov              = imgui.ImInt(30)
local hGov              = imgui.ImInt(15)
local gosScreen         = imgui.ImBool(true)
local gosDep            = imgui.ImBool(true)
local typeLect          = imgui.ImInt(1)
local lect_edit_name    = imgui.ImBuffer(256)
local lect_edit_text    = imgui.ImBuffer(65536)
local delayGov          = imgui.ImInt(2500)
local blacklist 		= imgui.ImBuffer(256)
local chat_calc			= imgui.ImBool(cfg.main.chat_calc)
local infoupdate        = imgui.ImBool(cfg.main.infoupdate)
local loginupdate       = imgui.ImBool(cfg.main.loginupdate)
local ki_stat           = imgui.ImBool(cfg.main.ki_stat)
local rank              = imgui.ImInt(cfg.main.rank)
local sex               = imgui.ImInt(cfg.main.sex)
local autoF8            = imgui.ImBool(cfg.main.autoF8)
local upWithRp          = imgui.ImBool(cfg.main.upWithRp)
local LectDelay         = imgui.ImInt(cfg.main.LectDelay)
local MsgDelay			= imgui.ImFloat(cfg.main.MsgDelay)
local rpbat             = imgui.ImBool(cfg.main.rpbat)
local rpbat_true        = imgui.ImBuffer(u8(cfg.main.rpbat_true), 256) 
local rpbat_false       = imgui.ImBuffer(u8(cfg.main.rpbat_false), 256)
local colorRchat        = imgui.ImFloat4(imgui.ImColor(cfg.main.colorRchat):GetFloat4())
local colorDchat        = imgui.ImFloat4(imgui.ImColor(cfg.main.colorDchat):GetFloat4())
local colorCosmo        = imgui.ImFloat4(imgui.ImColor(cfg.main.colorCosmo):GetFloat4())
local black_theme       = imgui.ImBool(cfg.main.black_theme)
local forma_post        = imgui.ImBuffer(u8(cfg.main.forma_post), 256)
local forma_lect        = imgui.ImBuffer(u8(cfg.main.forma_lect), 256)
local forma_tr          = imgui.ImBuffer(u8(cfg.main.forma_tr), 256)
local accent_status     = imgui.ImBool(cfg.main.accent_status)
local accent            = imgui.ImBuffer(u8(cfg.main.accent), 256)
local glass_light       = imgui.ImFloat(cfg.main.glass_light)
local glass_light_child = imgui.ImFloat(cfg.main.glass_light_child)
local timeF9            = imgui.ImBool(cfg.main.timeF9)
local expelReason       = imgui.ImBuffer(u8(cfg.main.expelReason), 256)
local kassa = {
	stat = imgui.ImBool(false),
	name = imgui.ImBuffer(256),
	time = imgui.ImBuffer(256),
	pos = {x = 0, y = 0, z = 0},
	money = 0
}

local govstr = {
	[1] = imgui.ImBuffer(u8(cfg.govstr[1]), 256),
	[2] = imgui.ImBuffer(u8(cfg.govstr[2]), 256),
	[3] = imgui.ImBuffer(u8(cfg.govstr[3]), 256)
}

local govdep = { 
	[1] = imgui.ImBuffer(u8(cfg.govdep[1]), 256),
	[2] = imgui.ImBuffer(u8(cfg.govdep[2]), 256),
}

local chat = {
	['expel'] = imgui.ImBool(cfg.Chat.expel),
	['shtrafs'] = imgui.ImBool(cfg.Chat.shtrafs),
	['incazna'] = imgui.ImBool(cfg.Chat.incazna),
	['invite'] = imgui.ImBool(cfg.Chat.invite),
	['uval'] = imgui.ImBool(cfg.Chat.uval)
}

local SCRIPT_STYLE = {
	colors = {
		['B'] = black_theme.v and imgui.ImVec4(0.10, 0.10, 0.11, 1.00) or imgui.ImVec4(0.95, 0.95, 0.95, 1.00),
		['E'] = black_theme.v and imgui.ImVec4(0.00, 0.40, 0.60, 1.00) or imgui.ImVec4(0.00, 0.40, 0.60, 1.00),
		['T'] = black_theme.v and imgui.ImVec4(1.00, 1.00, 1.00, 1.00) or imgui.ImVec4(0.20, 0.20, 0.20, 1.00),
	},
	clock = nil
}

local notf_sX, notf_sY = convertGameScreenCoordsToWindowScreenCoords(630, 438)
local notify = {
	messages = {},
	active = 0,
	max = 6,
	list = {
		pos = { x = notf_sX - 200, y = notf_sY },
		npos = { x = notf_sX - 200, y = notf_sY },
		size = { x = 200, y = 0 }
	}
}

local await = {}

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	log('?????? ?????????? ? ???????..', "??????????")

	if loginupdate.v then autoupdate(jsn_upd) end

	if not doesFileExist('moonloader/config/Bank_Config.ini') then
		if inicfg.save(cfg, 'Bank_Config.ini') then log('?????? ???? Bank_Config.ini', "??????????") end
	end

	if checkData() then
		log('???????? ?????? ?????? ???????!', "??????????")
	end

	if not checkServer(select(1, sampGetCurrentServerAddress())) then
		addBankMessage('?????? ???????? ?????? ?? ??????? {M}Arizona RP')
		unload(false)
	end

	log('?????? ????? ? ??????!', "??????????")
	bratishka = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))):find('Cosmo')
	addNotify("??????? ????: {006AC2}/bank\n??????????????: {006AC2}??? + Q", 5)
	addNotify("??????? ??????: {006AC2}"..thisScript().version.."\n?????? ????????!", 5)

	if cfg.main.infoupdate then
		infoupdate.v = true
		cfg.main.infoupdate = false
		inicfg.save(cfg, 'Bank_Config.ini')
	end

	sampRegisterChatCommand('bank', function()
		bank.v = not bank.v
	end)

	if sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 'Jeffy_Cosmo' then
		log('?? ????? ??? ???????????!')
		devmode = true
	end

	sampRegisterChatCommand('setrankdev', function(rank)
		rank = tonumber(rank)
		if devmode and rank and rank >= 1 and rank <= 10 then
			cfg.main.rank = tonumber(rank)
			addBankMessage(string.format('???????? ???? [%s] ?????', rank))
		end
	end)

	sampRegisterChatCommand('kip', function()
		if not kassa['stat'].v then 
			addBankMessage('???????? ?? ???? ??? ???????? ?????? ? ??????????')
			return false
		end

		lua_thread.create(function()
			local backup = {
				['x'] = cfg.main.KipX,
				['y'] = cfg.main.KipY
			}
			local ChangePos = true
			showCursor(true, true)
			sampSetCursorMode(4)
			addBankMessage('??????? {M}??????{W} ???-?? ????????? ??????????????, ??? {M}ESC{W} ???-?? ????????')
			while ChangePos == true do
				wait(0)
				local cX, cY = getCursorPos()
				cfg.main.KipX = cX
				cfg.main.KipY = cY
				if isKeyJustPressed(VK_SPACE) then
					ChangePos = false
					addBankMessage('??????? ?????????!')
				elseif isKeyJustPressed(VK_ESCAPE) then
					ChangePos = false
					cfg.main.KipX = backup['x']
					cfg.main.KipY = backup['y']
					addBankMessage('?? ???????? ????????? ??????????????')
				end
			end
			showCursor(false, false)
			sampSetCursorMode(0)
		end)
	end)

	sampRegisterChatCommand('ustav', function()
		ustav_window.v = not ustav_window.v
	end)

	sampRegisterChatCommand('ro', function(text)
		if cfg.main.rank >= 9 or bratishka then
			if #text > 0 then
				sampSendChat('/r [??????????] '..text)
			else
				addBankMessage('????????? /ro [text]')
			end
		else
			addBankMessage('???????? ?????? ? 9 ?????')
		end
	end)
	sampRegisterChatCommand('rbo', function(text)
		if cfg.main.rank >= 9 or bratishka then
			if #text > 0 then
				sampSendChat('/rb [??????????] '..text)
			end
			addBankMessage('????????? /rbo [text]')
			return
		end
		addBankMessage('???????? ?????? ? 9 ?????')
		return
	end)

	sampRegisterChatCommand('fwarn', function(args)
		if cfg.main.rank >= 9 or devmode then
			local id, reason = args:match('^%s*(%d+) (.+)')
			if id ~= nil and reason ~= nil then
				id = tonumber(id)
				if sampIsPlayerConnected(id) then
					play_message(MsgDelay.v, true, {
						{ "/me {sex:??????|???????} ?? ???????? ?????? ????????????" },
						{ "/me {sex:??????|???????} ?????????? %s", rpNick(id) },
						{ "/me ? ???? {sex:??????|???????} ????? ??????? ????????" },
						{ "/fwarn %s %s", id, reason }
					})
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /fwarn [id] [???????]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('invite', function(id)
		if cfg.main.rank >= 9 or devmode then
			local id = tonumber(id)
			if id ~= nil then
				if sampIsPlayerConnected(id) then
					if not isPlayerOnBlacklist(sampGetPlayerNickname(id)) then 
						play_message(MsgDelay.v, true, {
							{ "/me {sex:??????|???????} ??????? ? {sex:??????|???????} ???? ??????" },
							{ "/me {sex:???????|???????} ? ?????? ???????????? ? {sex:????|??????} ???? ?????? ?????????? %s", rpNick(id) },
							{ "/me {sex:???????|????????} ?????????? ????? ?? ????????" },
							{ "/invite %s", id }
						})
						return
					end
					addBankMessage('?? ?? ?????? ??????? ????? ?????? ?? ???????!')
					addBankMessage(string.format('????? {M}%s{W} ????????? ? {FF0000}?????? ??????{W}!', rpNick(id)))
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /invite [id]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('giverank', function(args)
		if cfg.main.rank >= 9 or devmode then
			local id, rank = args:match('^%s*(%d+) (%d+)')
			if id ~= nil and rank ~= nil then
				id, rank = tonumber(id), tonumber(rank)
				local result, dist = getDistBetweenPlayers(id)
				if result and dist < 5 then
					if rank >= 1 and rank <= 9 then
						play_message(MsgDelay.v, true, {
							{ "/me {sex:??????|???????} ?? ??????? ???" },
							{ "/me {sex:???????|????????} ??? ? {sex:?????|?????} ? ?????? ????????????" },
							{ "/me {sex:??????|???????} ?????????? %s", rpNick(id) },
							{ "/me {sex:???????|????????} ????????? ?????????? ?? ?%s?", cfg.nameRank[rank] },
							{ "/giverank %s %s", id, rank }
						})
						return
					end
					addBankMessage('??????? ????????? ?? 1 ?? 9!')
					return
				end
				addBankMessage('?? ?????? ?? ????? ??????????!')
				return
			end
			addBankMessage('?????????: /giverank [id] [????]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('uninvite', function(args)
		if cfg.main.rank >= 9 or devmode then
			local id, reason = args:match('^%s*(%d+) (.+)')
			if id ~= nil and reason ~= nil then
				id = tonumber(id)
				if sampIsPlayerConnected(id) then
					play_message(MsgDelay.v, true, {
						{ "/me {sex:??????|???????} ??????? ? {sex:??????|???????} ???? ??????" },
						{ "/me {sex:???????|???????} ? ?????? ???????????? ? {sex:?????|?????} ??? %s", rpNick(id) },
						{ "/me {sex:??????|???????} ?????????? ? {sex:?????|??????} ?????????" },
						{ "/uninvite %s %s", id, reason }
					})
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /uninvite [id] [???????]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('blacklist', function(args)
		if cfg.main.rank >= 9 or devmode then
			local id, reason = args:match('^%s*(%d+) (.+)')
			if id ~= nil and reason ~= nil then
				id = tonumber(id)
				if sampIsPlayerConnected(id) then
					play_message(MsgDelay.v, true, {
						{ "/me {sex:??????|???????} ?? ???????? ?????? ?׸???? ???????" },
						{ "/me ? ???? {sex:??????|???????} ????? ??????????" },
						{ "/me {sex:????|??????} ?????????? %s ? ?????? ?????? ?????", rpNick(id) },
						{ "/blacklist %s %s", id, reason }
					})
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /blacklist [id] [???????]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('unblacklist', function(id)
		if cfg.main.rank >= 9 or devmode then
			id = tonumber(id)
			if id ~= nil then
				if sampIsPlayerConnected(id) then
					play_message(MsgDelay.v, true, {
						{ "/me {sex:??????|???????} ?? ???????? ?????? ?׸???? ???????" },
						{ "/me ? ???? {sex:??????|???????} ????? ???????????" },
						{ "/me {sex:????????|?????????} ?????????? %s ?? ??????? ?????? ?????", rpNick(id) },
						{ "/unblacklist %s", id }
					})
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /unblacklist [id]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return
	end)

	sampRegisterChatCommand('unfwarn', function(id)
		if cfg.main.rank >= 9 or devmode then
			id = tonumber(id)
			if id ~= nil then
				if sampIsPlayerConnected(id) then
					play_message(MsgDelay.v, true, {
						{ "/me {sex:??????|???????} ?? ???????? ?????? ????????????" },
						{ "/me {sex:??????|???????} ?????????? %s", rpNick(id) },
						{ "/me ? ???? {sex:??????|???????} ????? ?????? ????????" },
						{ "/unfwarn %s", id }
					})
					return
				end
				addBankMessage('?????? ?????? ??? ? ????!')
				return
			end
			addBankMessage('?????????: /unfwarn [id]')
			return
		end
		addBankMessage('??????? ???????? ?????? ? 9-??? ?????')
		return  
	end)

	lua_thread.create(function()
		while not sampIsLocalPlayerSpawned() do wait(1000) end
		if sampIsLocalPlayerSpawned() then
			await['get_rank'] = os.clock()
			sampSendChat('/stats')
		end
	end)
 	
	while true do

		if cfg.main.timeF9 then 
			if isKeyJustPressed(VK_F9) then 
				sampSendChat('/time')
			end
		end

		if cfg.main.rpbat then 
			frpbat()
		end

		local result, id = sampGetPlayerIdOnTargetKey(VK_Q)
		if result then
			if getCharActiveInterior(PLAYER_PED) ~= 0 or devmode then
				addBankMessage('????????? {M}Esc{W} ??? ?? ??????? ????')
				actionId = id
				int_bank.v = true
			else
				addBankMessage('???????? ?????? ? ?????????!')
			end
		end

		local result, id = sampGetPlayerIdOnTargetKey(VK_G)
		if result and isUniformWearing() then
			go_expel(id)
		end

		local result, id = sampGetPlayerIdOnTargetKey(VK_R)
		if result then
			actionId = id
			addBankMessage(string.format('????? {M}%s{W} ?????? ? ???????? ???????? {M}{select_id/name}', rpNick(actionId)))
		end

		if testCheat('BB') and not bank.v and not int_bank.v then
			type_window.v = 1
			bank.v = true
		end

		if sampGetChatInputText() == '!????' then
			sampSetChatInputText(cfg.main.forma_post)
			sampSetChatInputCursor(0, 0)
		end
		if sampGetChatInputText() == '!??????' then
			sampSetChatInputText(cfg.main.forma_lect)
			sampSetChatInputCursor(0, 0)
		end
		if sampGetChatInputText() == '!?????' then
			sampSetChatInputText(cfg.main.forma_tr)
			sampSetChatInputCursor(0, 0)
		end

		if not bratishka and cfg.main.colorCosmo ~= 4288216832 then 
			cfg.main.colorCosmo = 4288216832 
		end

		if status_button_gov then 
			if tonumber(os.date("%S", os.time())) == 00 and antiflud then
				if tonumber(os.date("%H", os.time())) == hGov.v and tonumber(os.date("%M", os.time())) == mGov.v - 1 then
					antiflud = false
					addNotify("????? {006AC2}??????{SSSSSS} GOV ?????\n{006D86}??????????? ? ????!", 10)
				end
			end
			if tonumber(os.date("%H", os.time())) == hGov.v and tonumber(os.date("%M", os.time())) == mGov.v then 
				status_button_gov = false
				goGov()
			end
		end

		if sampIsChatInputActive() and chat_calc.v then
			local example = sampGetChatInputText()
			if example:match('[0-9]+') and example:match('[-+/*^]+') then
		        local result, answer = pcall(load('return ' .. example))
		        if result then
			        local element = getStructElement(sampGetInputInfoPtr(), 0x8, 4)
			        local X = getStructElement(element, 0x8, 4)
			        local Y = getStructElement(element, 0xC, 4) + 45
			        local res, format = pcall(sumFormat, answer)
			        local output = string.format('?????????: {00AAFF}%s', res and format or answer)
			        local l = renderGetFontDrawTextLength(calc_font, output)
			        local h = renderGetFontDrawHeight(calc_font)
			        renderDrawBox(X, Y, l + 15, h + 15, 0xFF101010)
			        renderFontDrawText(calc_font, output, X + 7.5, Y + 7.5, 0xFFFFFFFF)
			    end
		    end
		end

		if SPEAKING and isKeyDown(VK_CONTROL) and isKeyJustPressed(VK_BACK) then
			SPEAKING:terminate(); SPEAKING = nil
			addBankMessage('????????? ??????? ????????!')
		end

		if bank.v or int_bank.v or ustav_window.v or infoupdate.v then 
			imgui.ShowCursor = true
			imgui.Process = true
		elseif kassa['stat'].v or #notify.messages > 0 then
			imgui.ShowCursor = false
			imgui.SetMouseCursor(-1)
			imgui.Process = true
		else
			imgui.Process = false
		end

	wait(0)
	end
end

function play_message(delay, screen, text_array)
	if SPEAKING ~= nil then
		addBankMessage('? ??? ??? ??????????????? ?????-?? ?????????, ????????? ?? ?????????!')
		addBankMessage('???????? ??????? ?????????: {M}Ctrl {W}+{M} Backspace!')
		return false
	end
	SPEAKING = lua_thread.create(function()
		for i, line in ipairs(text_array) do
			sampSendChat(string.format(line[1], table.unpack(line, 2)))
			if i ~= #text_array then
				wait(delay * 1000)
			elseif screen == true then
				wait(1000)
				takeAutoScreen()
			end
		end
		SPEAKING = nil
	end)
	return true
end

function se.onGivePlayerMoney(count)
	if kassa['stat'].v and count > 0 then
		kassa['money'] = kassa['money'] + count
	end
end

function se.onCreatePickup(id, model, pickupType, position)
	if model == 18631 then 
		return {id, 1274, pickupType, position} -- $$$ Dollar $$$
	end
end

function se.onCreate3DText(id, color, position, distance, testLOS, attachedPlayerId, attachedVehicleId, text)
	if ki_stat.v then
		if text:find('?????') and text:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))) then
			kassa['pos'] = {x = position.x, y = position.y, z = position.z}
			kassa['stat'].v = true
			kassa['name'].v = text:match('??????? ?????: (.+)\n\n?????????')
			kassa['time'].v = tostring(text:match('?? ?????: {FFA441}(%d+){FFFFFF} ?????'))
			if kassa['time'].v:match('^0') then 
				addBankMessage(string.format('?? ?????? ?? ????: {M}%s{W}! ????? ???????? ?????????????? ?????? ?????????? ??????? {W}/kip', kassa['name'].v)) 
				kassa['money'] = 0
			end
			return false
		end
		if kassa['name'].v ~= '' and text:find(kassa['name'].v) and text:find('????????') then
			kassa['name'].v = ''
			kassa['stat'].v = false
		end
	end
end

function rpNick(id)
	local nick = sampGetPlayerNickname(id)
	if nick:match('_') then return nick:gsub('_', ' ') end
	return nick
end

function goGov()
	lua_thread.create(function()
		if gosDep.v and #govdep[1].v > 0 then sampSendChat('/d '..u8:decode(govdep[1].v)) end
		if #govstr[1].v > 0 then wait(delayGov.v); sampSendChat('/gov '..u8:decode(govstr[1].v)) end
		if #govstr[2].v > 0 then wait(delayGov.v); sampSendChat('/gov '..u8:decode(govstr[2].v)) end
		if #govstr[3].v > 0 then wait(delayGov.v); sampSendChat('/gov '..u8:decode(govstr[3].v)) end
		if gosDep.v and #govdep[1].v > 0 then wait(delayGov.v); sampSendChat('/d '..u8:decode(govdep[2].v)) end
		if gosScreen.v then wait(500); sampSendChat('{screen}') end
	end)
end

function se.onServerMessage(clr, msg) -- ??? ????
	local send = function(message)
		math.randomseed(os.clock())
		lua_thread.create(function()
			wait(200 + math.random(-100, 100))
			sampSendChat(message)
		end)
	end

	if msg:match('^%* [a-zA-Z_]+ ??????? [a-zA-Z_]+ ??? ?????? ???????') then
		local player1, player2 = msg:match('^%* ([a-zA-Z_]+) ??????? ([a-zA-Z_]+) ??? ?????? ???????')
		local id1, id2 = getPlayerIdByNickname(player1), getPlayerIdByNickname(player2)
		if id1 and id2 then 
			local color1, color2 = sampGetPlayerColor(id1), sampGetPlayerColor(id2)
			if color1 == color2 then 
				sampAddChatMessage('[Warning] ???????? ?? ?? ?????????? '..player1..'('..id1..')', 0xAA3333)
			end
			local msg = msg:gsub(player1, player1..'('..id1..')')
			local msg = msg:gsub(player2, player2..'('..id2..')')
			return {clr, msg}
		end
	end

	if msg:find('???????????: /jobprogress %[ ID ?????? %]') then
		return false
	end

	local leader, rank = msg:match('^????? [A-z0-9_]+ ??????? ?? %d+ ?????')
	if leader and rank then
		cfg.main.dateuprank = os.time()
		await['get_rank'] = os.clock()
		await['rank_update'] = os.clock()
		send('/stats')
		return false
	end

	if msg:find('^????? ????? ??????????? [A-z0-9_]+ ??????? ??? ? ?????????') then
		cfg.main.dateuprank = os.time()
		await['get_rank'] = os.clock()
		await['rank_update'] = os.clock()
		send('/stats')
		return false
	end

	if msg:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))..' ????????????? ? ??????????? ??????') then
		addNotify('{006D86}??????? ???? ???????!\n?????? ?????????!', 5)
		return false
	end

	if msg:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))..' ????????????? ? ??????? ??????') then
		addNotify('{006D86}?? ?????? ??????? ????!\n????????????? ???!', 5)
		return false
	end

	local member, client, reason = msg:match('%[i%] (.+){FFFFFF} ?????? (.+) ?? ?????! ???????: (.+)')
	if member and client and reason then 
		if chat['expel'].v then
			msg = string.format(tag.. '????????? %s ?????? ?? ????? %s ?? ???????: %s', mc .. member .. wc, mc .. client .. wc, mc .. reason)
			return { 0x006699FF, msg }
		end
		return false
	end

	local sum, nick = msg:match('^%[????%] {%x+}??????????? ???????? (%d+%$) %(16 ?????????%) ?? ?????? ?????? ??????? ([A-z0-9_]+)')
	if sum and nick then 
		if chat['shtrafs'].v then
			msg = string.format(tag .. '????? ????? ????????? ?? %s. ?????? %s ???? ?????? ?? ?????', mc .. sum .. wc, mc .. nick:gsub('_', ' ') .. wc)
			return { 0x006699FF, msg }
		end
		return false
	elseif msg:find('^????????? ?????? ???? ???????????? ????? ???????? ?????') and chat['shtrafs'].v then
		return false
	end

	local nick, sum = msg:match('^{%x+}([A-z0-9_]+) {%x+}???????? ???? ??????????? ?? {%x+}(%d+%$)')
	if nick and sum then 
		if chat['incazna'].v then
			msg = string.format(tag .. '????????? %s ???????? ????? ????? ?? %s', mc .. nick:gsub('_', ' ') .. wc, mc .. sum .. wc)
			return { 0x006699FF, msg }
		end
		return false
	end

	local member, leader = msg:match('^???????????? ?????? ????? ????? ??????????? ([A-z0-9_]+), ???????? ?????????: ([A-z0-9_]+)')
	if member and leader then 
		if chat['invite'].v then
			msg = string.format(tag .. '%s - ????? ???? ????? ???????????. ?????????: %s', mc .. member:gsub('_', ' ') .. wc, mc .. leader:gsub('_', ' ') .. wc)
			return { 0x006699FF, msg }
		end
		return false
	end

	local leader, member, reason = string.match(msg, '{FFFFFF}(.+) ?????? (.+) ?? ???????????. ???????: (.+)')
	if leader and member and reason then 
		if chat['uval'].v then
			msg = string.format(tag .. '???????????? %s ?????? ?????????? %s ?? ???????: %s', mc .. leader:gsub('_', ' ') .. wc, mc .. member:gsub('_', ' ') .. wc, wc .. reason)
			return { 0x006699FF, msg }
		end
		return false
	end

	local accepted = string.match(msg, '%[??????????%] {FFFFFF}?? ??????? ?????? ?????? ?????? {73B461}(.+)')
	if accepted then
		addNotify("{006D86}????????!\n?????? ????????!", 8)
		return false
	end

	if msg:find('^%[R%]') and clr == 0x2DB043FF then
		if msg:find('%[??????????%]') and {msg:find(cfg.nameRank[9], 1, true) or msg:find(cfg.nameRank[10], 1, true) or bratishka} then
			msg = msg:gsub('%[??????????%] ', '', 1)
			msg = msg:gsub('^%[R%]', '[??????????]', 1)
			clr = 0xFFAE00FF
		else
			if msg:find(':%(%( ?????? ??? ??????????? ?? ????????? .+ %)%)$') then
				rank_prem = msg:match(':%(%( ?????? ??? ??????????? ?? ????????? (.+) %)%)$')
				return false
			end
			local cR, cG, cB, cA = imgui.ImColor(cfg.main.colorRchat):GetRGBA()
			local nR, nG, nB, nA = imgui.ImColor(cfg.main.colorCosmo):GetRGBA()
			local nick = msg:match('([A-z0-9_]+%[%d+%]):')
			if nick and nick:find('_Cosmo', 1, true) then
				msg = msg:gsub('[A-z0-9_]+%[%d+%]', string.format('{%06X}' .. nick .. '{%06X}', join_rgb(nR, nG, nB), join_rgb(cR, cG, cB)), 1)
			end
			clr = join_argb(cR, cG, cB, cA)
		end
		return { clr, msg }
	end

	if msg:match('^%[D%].*%[%d+%]:') and clr == 0x3399FFFF then
		local r, g, b, a = imgui.ImColor(cfg.main.colorDchat):GetRGBA()
		return { join_argb(r, g, b, a), msg }
	end

	if msg:find('%[??????%] {FFFFFF}??? ?????? ????????? ?? ????????? ???????!') then
		addNotify("{006D86}?????? ????????!\n?????? ?????????", 8)
		await['credit_send'] = nil
		return false
	end
	if msg:find('%[??????%] {FFFFFF}? ????? ???????? ??? ???? ????????????? ? ?????!') and await['credit_send'] then
		addNotify("? ???????? ??? ????\n??????????? ??????!", 8)
		sampSendChat('? ?????????, ??????????, ??? ?? ??? ??? ???????? ???? ??????, ???????? ??????? ???')
		await['credit_send'] = nil
		return false
	end

	if msg:find('%[??????%] {FFFFFF}?? ?????? ?? ??????!') or msg:find('^???????? ? ???????') then 
		await = {}
	end

	if msg:find('%[??????%] {FFFFFF}? ????? ???????? ??? ???? ?????????? ?????!') then 
		await['card_create'] = nil
		addNotify("{006D86}???????? ????????!\n????? ??? ??????????", 5)
		return false
	end
	
	if msg:find('%[??????%] {FFFFFF}? ????? ???????? ???????????? ???????!') and await['card_create'] then
		addNotify("{006D86}???????? ????????!\n???????????? ???????", 8)
		sampSendChat('?????? ?????? ????? 3.000$, ? ???, ??? ? ???? ????? ????? ???, ????????? ? ?????? ???')
		await['card_create'] = nil
		return false
	end

	if msg:find('%[??????????%] {FFFFFF}?? ???????? ????!') then 
		kassa['stat'].v = false
		addNotify('{006D86}????:\n?? ???????? ????!', 5)
		return false
	end

	if msg:find('???? ? ????? ???????? ? 5-?? ?????!', 1, true) then 
		return false
	end

	if msg:find('????? ?????? %(%d+%) ???? ?????? ???????????') and clr == -218038273 then
		local leader, sum = msg:match('([A-z0-9_]+)%[%d+%] ????? ?????? %((%d+)%) ???? ?????? ???????????')
		if leader and sum then
			leader = leader:gsub('_', ' ')
			sum = sumFormat(sum)
			if rank_prem ~= nil then
				msg = string.format('???????????? %s ????? ?????? ? ??????? %s$ ??????????? ?? ????????? %s', leader, sum, rank_prem)
			else
				msg = string.format('???????????? %s ????? ?????? ? ??????? %s$ ??????????? ?? ???????????? ?????????', leader, sum)
			end
			return { clr, msg }
		end
	end
end

function se.onShowDialog(dialogId, style, title, button1, button2, text) -- ??? ????????
	local isAnyAwaitExist = false
	for k, v in pairs(await) do
		if os.clock() - v > 60.0 then
			await[k] = nil
		else
			isAnyAwaitExist = true
		end
	end

	local send = function(...)
		local args = {...}
		local onChat = (#args == 1 and type(args[1]) == 'string')
		math.randomseed(os.clock())
		local cooldown = 200 + math.random(-100, 100)
		lua_thread.create(function(); wait(cooldown)
			if onChat then
				sampSendChat(args[1])
			else
				sampSendDialogResponse(dialogId, args[1], args[2], args[3], args[4])
			end
		end)
	end

	-- /bankmenu
	if dialogId == 713 and isAnyAwaitExist then
		if await['credit_send'] then 		send(1, 0)
		elseif await['debt'] then 			send(1, 1)
		elseif await['get_money'] then 		send(1, 2)
		elseif await['card_create'] then 	send(1, 3)
		elseif await['card_recreate'] then 	send(1, 4)
		elseif await['dep_plus'] then 		send(1, 5)
		elseif await['dep_minus'] then 		send(1, 6)
		elseif await['dep_check'] then 		send(1, 7)
		end; await = {}
		return false
	end

	-- Information dialogs
	if dialogId == 0 and isAnyAwaitExist then
		if await['card_create'] then await = {} end
		local kd = text:match('????? {%x}(%d+){%x} ???.+')
		if kd then
			kd = tonumber(kd)
			if await['dep_minus'] and schet_dep[kd] ~= nil then
				addNotify("{006D86}???????? ????????!\n? ??????? ?? ?? ??????", 6)
				send(string.format('????????, ?? ????? ? ???????? ?? ??????? ?????? ????? %s %s', kd, plural(kd, {'???', '????', '?????'})))
				send(1); await['dep_minus'] = nil
				return false
			elseif await['dep_check'] then
				send(string.format('??????? ?????? ? ???????? ?? ??????? ????? %s', kd, plural(kd, {'???', '????', '?????'})))
				send(1); await['dep_check'] = nil
				return false
			end
		end

		if text:find('?? ??????? ????????? ??????????? ?? ????? ??????') then
			addNotify("{006D86}????????..\n??????????? ??????????", 5)
			if kassa['stat'].v then cfg.kassa.recard = cfg.kassa.recard + 1 end
			send(0)
			return false
		end

		if text:find('?? ??????? ???? {73B461}??????{FFFFFF} ?????, ??? ?????????? ????????') then
			addNotify("{006D86}????????..\n??????????? ??????????", 5)
			if kassa['stat'].v then cfg.kassa.dep = cfg.kassa.dep + 1 end
			send(0)
			return false
		end

		if text:find('?? ??????? ???? ?????? {73B461}?????{FFFFFF}, ??? ????????? ?????? ????????') then
			addNotify("{006D86}????????..\n??????????? ??????????", 5)
			if kassa['stat'].v then cfg.kassa.dep = cfg.kassa.dep + 1 end
			send(0)
			return false
		end

		if text:find('????? ?????????? ?????????? ?????') then
			addNotify("{006D86}????????..\n??????????? ??????????", 5)
			if kassa['stat'].v then cfg.kassa.card = cfg.kassa.card + 1 end
			send(0)
			return false
		end

		if text:find('?????? ???????') then
			text = text:gsub(
				'%- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- {73B461}?????? ???????{FFFFFF} %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %- %-\n',
				'{FFFFFF}- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - {73B461}?????? ???????{FFFFFF} - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n'  
			)
			text = separator(text)
			return { dialogId, style, title, button1, button2, text }
		end

		if text:find('PIN-??? ??????', 1, true) then
			send(1)
			addBankMessage('PIN-??? ??????!')
			lua_thread.create(function() -- N
				wait(0) setGameKeyState(10, 255)
				wait(0) setGameKeyState(10, 0)
			end)
			return false
		end
	end
	
	-- Credit sum
	if dialogId == 227 and await['credit_send'] then
		if type(credit_sum.v) == 'number' then
			send(1, nil, credit_sum.v)
		end
		return false
	end

	-- Credit accept
	if dialogId == 228 and await['credit_send'] then
		addNotify("{006D86}??????????? ??????????\n????????? ?????????", 5)
		send(1); await['credit_send'] = nil
		if kassa['stat'].v then 
			cfg.kassa.credit = cfg.kassa.credit + 1 
		end 
		return false
	end
	
	-- Report
	if dialogId == 32 and await['report'] then
		addNotify("{006D86}?????? ?????????!\n???????? ??????", 5)
		send(0); await['report'] = nil 
		return false
	end

	if dialogId == 235 and await['get_rank'] then
		if not text:find('??????????? ????') and not devmode then
			lua_thread.create(function()
				wait(2000)
				addBankMessage('?? ?? ? ??????????? {M}???????????? ?????')
				addBankMessage('?????? ???????? ?????? ? ???? ???????????')
				addBankMessage('???? ?? ????????, ??? ??? ?????? - ???????? ???????????? {M}vk.com/opasanya')
				addBankMessage('?????? ????????..')
				log('?????? ????????. ?? ?? ? ??????????? "??????????? ????"')
				unload(false)
			end)
			return false
		end

		for line in text:gmatch('[^\r\n]+') do
			local name, rank = line:match('^{%x+}?????????: {%x+}(.+)%((%d+)%)')
			if rank then
				rank = tonumber(rank)
				if rank ~= cfg.main.rank then
					cfg.main.rank = rank
					if inicfg.save(cfg, 'Bank_Config.ini') and await['rank_update'] then 
						await['rank_update'] = nil
						addBankMessage(string.format('???? ????????? ????????? ?? {M}%s(%s)', name, rank))
					end
				elseif await['rank_update'] then
					await['rank_update'] = nil
					addBankMessage('?????????????? ????? ????????? ?? ??????????!')
				end
			end
		end

		send(0); await['get_rank'] = nil
		return false
	end

	if dialogId == 2015 then 
		for line in text:gmatch('[^\r\n]+') do
			local name, rank = line:match('^{%x+}[A-z0-9_]+%([0-9]+%)\t(.+)%(([0-9]+)%)\t%d+\t%d+')
			if name and rank then
				name, rank = tostring(name), tonumber(rank)
				if cfg.nameRank[rank] ~= nil and cfg.nameRank[rank] ~= name then
					addBankMessage(string.format('????????? ???????? ?????: {M}%s{W} -> {M}%s{W} | {S}%s ????', cfg.nameRank[rank], name, rank))
					cfg.nameRank[rank] = name
				end
			end
		end
		send(0)
	end

	if title:find('????????????') and await['uprankdate'] then 
		local day, month, year, hour, min, sec = text:match('(%d+)%.(%d+)%.(%d+) (%d+):(%d+):(%d+)')
		if day ~= nil then
			local dt = {
				day = day, month = month, year = year,
				hour = hour, min = min, sec = sec
			}
			cfg.main.dateuprank = os.time(dt)
			addBankMessage(string.format('???? ?????????? ????????? ?? /jobprogress: {M}%s', os.date('%d.%m.%Y %H:%M:%S', os.time(dt))))
		else
			addBankMessage('?? ??????? ????????? ???? ????????? ?? /jobprogress!')
		end
		await['uprankdate'] = nil
		send(0)
		return false
	end
end

function separator(text)
	local format = text:gsub('{%x+}', '')
	for d in format:gmatch("%d+") do
		local result, out = pcall(sumFormat, d)
		text = text:gsub(d, result and out or d)
	end
	return text
end

font = {}
function imgui.BeforeDrawFrame()
	local config = imgui.ImFontConfig()
    config.MergeMode, config.PixelSnapH = true, true
    local range = {
    	text = imgui.GetIO().Fonts:GetGlyphRangesCyrillic(),
    	icon = imgui.ImGlyphRanges({ 0xf000, 0xf83e })
    }
    
    if default_font_icons == nil then
    	default_font_icons = imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa_base, 13, config, range.icon)
    end
	for _, size in ipairs({ 11, 15, 20, 35, 45, 60 }) do
		if font[size] == nil then 
			font[size] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', size, nil, range.text) 
			imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa_base, size, config, range.icon)
		end
	end
end

function imgui.OnDrawFrame()
	local ex, ey = getScreenResolution()
	if int_bank.v then
		local _, selfid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local boolSkin, id_skin = sampGetPlayerSkin(actionId)
		imgui.SetNextWindowSize(imgui.ImVec2(465, 295), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(ex / 2, ey - 305), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0))
		imgui.Begin(u8'##IntMenuBank', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
			imgui.BeginChild("##ActionIdInfo", imgui.ImVec2(150, 180), true, imgui.WindowFlags.NoScrollbar)
			imgui.CenterTextColoredRGB(mc..'??? ??????')
			if sampIsPlayerConnected(actionId) then
				imgui.CenterTextColoredRGB(rpNick(actionId)..'['..actionId..']')
				if imgui.IsItemClicked() then
					if setClipboardText(u8:decode((sampGetPlayerNickname(actionId)))) then
						addBankMessage(string.format('??? {M}%s{W} ?????????? ? ????? ??????!', rpNick(actionId)))
					end
				else imgui.Hint('copytargetnick', u8'?????, ???-?? ???????????') end
				if TypeAction.v == 2 then
					if isPlayerOnBlacklist(sampGetPlayerNickname(actionId)) then
						imgui.CenterTextColoredRGB('{FF0000}׸???? ??????!')
					else
						imgui.NewLine()
					end
				else
					imgui.NewLine()
				end
				imgui.CenterTextColoredRGB(mc..'??? ? ?????')
				local yearold = sampGetPlayerScore(actionId)
				if TypeAction.v ~= 2 then 
					imgui.CenterTextColoredRGB(yearold..' ???')
				else
					imgui.CenterTextColoredRGB(yearold..' ??? | '..(yearold >= 3 and '????????' or '{FF0000}?? ????????'))
				end
			else
				int_bank.v = false
				addBankMessage('????? ????? ?? ????!')
			end
			imgui.NewLine()
			imgui.CenterTextColoredRGB(mc..'??? ????')
			if boolSkin then 
				imgui.CenterTextColoredRGB('???? ?'..id_skin)
				imgui.CenterTextColoredRGB(isSkinBad(id_skin) and '{FF0000}(?? ?????????)' or '(?????????)')
			else
				imgui.CenterTextColoredRGB('???? ?? ?????????')
			end
			imgui.EndChild()
			imgui.SameLine()
			if TypeAction.v == 2 or TypeAction.v == 3 then
				imgui.BeginChild("##Actions", imgui.ImVec2(-1, 275), true, imgui.WindowFlags.NoScrollbar)
			end
				if TypeAction.v == 1 then
					if not go_credit.v then
						imgui.SetCursorPos(imgui.ImVec2(165, 10))
						if imgui.Button(u8('??????????? ')..fa.ICON_FA_CHILD, imgui.ImVec2(200, 30)) then
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "/do ?? ????? ??????? ?%s?", cfg.nameRank[cfg.main.rank] },
								{ "????????????, ? %s - {my_name}", cfg.nameRank[cfg.main.rank] },
								{ "??? ???? ??? ???????" }
							})
						end
						imgui.SameLine()
						if cfg.main.rank > 1 then
							if imgui.Button(u8('??????? ')..fa.ICON_FA_BAN, imgui.ImVec2(-1, 30)) then
								imgui.OpenPopup("##edit_expel")
							end
						else
							imgui.DisableButton(u8('??????? ')..fa.ICON_FA_BAN, imgui.ImVec2(-1, 30))
							imgui.Hint('expel2rank', u8'???????? ? 2+ ?????')
						end
						if imgui.BeginPopupContextWindow("##edit_expel", 1, false) then
							imgui.PushItemWidth(150)
							imgui.Text(u8'??????? ??? /expel:')
							if imgui.InputText(u8'##ExpelReason', expelReason) then
								cfg.main.expelReason = u8:decode(expelReason.v)
							end
							imgui.PopItemWidth()
							if imgui.MainButton(u8'??????? ??????') then
								int_bank.v = false
								go_expel(tonumber(actionId))
							end
							imgui.EndPopup()
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 45))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('???????: ????? ')..fa.ICON_FA_MINUS_CIRCLE, imgui.ImVec2(250, 30)) then
								int_bank.v = false
								await['dep_minus'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ?????? ??????????" },
									{ "/me {sex:??????|???????} ????? ??????? ? {sex:?????|??????} ?????????????" },
									{ "/me {sex:????|?????} ????????????? ????? ? {sex:???????|????????} ??? %s", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(u8('???????: ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(250, 30))
							imgui.Hint('depositdown5rank', u8'???????? ? 5+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 80))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('???????: ????????? ')..fa.ICON_FA_PLUS_CIRCLE, imgui.ImVec2(250, 30)) then
								int_bank.v = false
								await['dep_plus'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ?????? ??????????" },
									{ "/me {sex:??????|???????} ????? ??????????? ? {sex:?????|??????} ?????????????" },
									{ "/me {sex:????|?????} ????????????? ????? ? {sex:???????|????????} ??? %s", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(u8('???????: ????????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(250, 30))
							imgui.Hint('depositeup5rank', u8'???????? ? 5+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 115))
						if cfg.main.rank > 5 then
							if imgui.Button(u8('?????? ?????? ')..fa.ICON_FA_CALCULATOR, imgui.ImVec2(-1, 30)) then
								go_credit.v = true
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ?????? ??????????????" },
									{ "/me {sex:??????|???????} ????? ??????????? ???????? ? {sex:?????|??????} ?????????????" },
									{ "/me {sex:????|?????} ????????????? ????? ? {sex:?????|??????} ????????? ???" },
									{ "????? ??? ???????, ???????????" }
								})
							end
						else
							imgui.DisableButton(u8('?????? ?????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 30))
							imgui.Hint('credit6rank', u8'???????? ? 6+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 150))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('?????? ???? ????? ')..fa.ICON_FA_MONEY_CHECK, imgui.ImVec2(-1, 30)) then
								int_bank.v = false
								await['debt'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ???? ??????" },
									{ "/me ????? ?? %s ???-?? ??????? ? ????", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(u8('?????? ???? ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 30))
							imgui.Hint('debt5rank', u8'???????? ? 5+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 185))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('?????? ???-?? ????? ? ????? ')..fa.ICON_FA_PIGGY_BANK, imgui.ImVec2(-1, 30)) then
								int_bank.v = false
								await['get_money'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ???? ??????" },
									{ "/me ????? ?? %s ???-?? ??????? ? ????", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(u8('?????? ???-?? ????? ? ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 30))
							imgui.Hint('howmuchmoney5rank', u8'???????? ? 5+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 220))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('?????? ????? ')..fa.ICON_FA_CREDIT_CARD, imgui.ImVec2(-1, 30)) then
								int_bank.v = false
								await['card_create'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ?????? ??????????? ??????" },
									{ "/me {sex:??????|???????} ????? ???????? ?????? ? {sex:?????|??????} ?????????????" },
									{ "/me {sex:????|?????} ????????????? ????? ? {sex:????????|?????????} ?????? ??????" },
									{ "/todo ????????? ???? ????? ? ????? ????!*?????? ?? %s", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(u8('?????? ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 30))
							imgui.Hint('givecard5rank', u8'???????? ? 5+ ?????')
						end
						imgui.SetCursorPos(imgui.ImVec2(165, 255))
						if cfg.main.rank > 4 then
							if imgui.Button(u8('???????????? ????? ')..fa.ICON_FA_RECYCLE, imgui.ImVec2(-1, 30)) then
								imgui.OpenPopup(u8("????? ????????##Card"))
							end
						else
							imgui.DisableButton(u8('???????????? ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 30))
							imgui.Hint('restorecard5rank', u8'???????? ? 5+ ?????')
						end
						if imgui.BeginPopupModal(u8("????? ????????##Card"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
							imgui.CenterTextColoredRGB(mc..'???????? ????????!\n???? ????? ???????? ???????, ??????\n???????? ?? ???? ? /report?')
							imgui.NewLine()
							if imgui.Button(u8('???????? ? /report'), imgui.ImVec2(150, 30)) then
								imgui.CloseCurrentPopup()
								await['report'] = os.clock()
								sampSendChat('/report')
								sampSendDialogResponse(32, 1, -1, '????????? '..rpNick(actionId)..'['..actionId..'] ?? ????? (????)')
							end
							imgui.SameLine()
							if imgui.Button(u8('??????????? ?????'), imgui.ImVec2(150, 30)) then
								imgui.CloseCurrentPopup()
								int_bank.v = false
								await['card_recreate'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "???????? ????????, ?????? ?????? ????????? ??? ? 30.000$" },
									{ "/me {sex:??????|???????} ?? ???????? ?????? ??????????? ??????" },
									{ "/me {sex:??????|???????} ????? ??????????? ????? ? {sex:?????|??????} ?????????????" },
									{ "/me {sex:????|?????} ????????????? ????? ? {sex:????????|?????????} ?????? ??????" },
									{ "/todo ????????? ??????? ??? ??? ??????? ? ????? ????*????????? ????? %s", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
							if imgui.MainButton(u8('?????'), imgui.ImVec2(-1, 30)) then
								imgui.CloseCurrentPopup()
							end
							imgui.EndPopup()
						end
						imgui.SetCursorPos(imgui.ImVec2(420, 45))
						if cfg.main.rank > 4 then
							if imgui.Button(fa.ICON_FA_CLOCK, imgui.ImVec2(35, 65)) then
								int_bank.v = false
								await['dep_check'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:??????|???????} ?? ???????? ???? ??????" },
									{ "/me ????? ?? %s ???-?? ??????? ? ????", rpNick(actionId) },
									{ "/bankmenu %s", actionId }
								})
							end
						else
							imgui.DisableButton(fa.ICON_FA_LOCK, imgui.ImVec2(35, 65))
							imgui.Hint('depositecheck5rank', u8'???????? ? 5+ ?????')
						end
					else
						imgui.BeginChild("##CreditWindow", imgui.ImVec2(-1, 275), true, imgui.WindowFlags.NoScrollbar)
							imgui.CenterTextColoredRGB(mc..'?????????? ??????? ??\n'..mc..'?????? '..sc..rpNick(actionId))
							imgui.NewLine()
							imgui.PushItemWidth(170)
							if imgui.InputInt(u8'????? ???????', credit_sum, 0, 0) then
								if credit_sum.v < 5000 then credit_sum.v = 5000 end
								if credit_sum.v > 300000 then credit_sum.v = 300000 end
							end
							imgui.PopItemWidth()
							imgui.NewLine()
							imgui.CenterTextColoredRGB(mc..'?????????? ??????? ????????????\n'..mc..'?? ????????????? ??????? ????????????\n'..sc..'???????????? ? ??? ?? ?????? ???:')
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 150) / 2)
							if imgui.Button(u8('??????? ????????????##credit'), imgui.ImVec2(150, 20)) then
								imgui.OpenPopup(u8("??????? ????????????"))
							end
							system_credit()
							imgui.NewLine()
							if imgui.MainButton(u8('?????? ?????? ?? '..credit_sum.v..'$'), imgui.ImVec2(-1, 30)) then
								go_credit.v = false
								int_bank.v = false
								await['credit_send'] = os.clock()
								play_message(MsgDelay.v, false, {
									{ "/me {sex:????????|?????????} ????????? ?????" },
									{ "/me ?????? ?????? ?????? ?? ??????????? ??????" },
									{ "/me ???????? ??????? ????? %s", rpNick(actionId) },
									{ "????????? ??????? ? ?????? ?????? ? ?????? ?????? %s$ ????? ????????!", credit_sum.v },
									{ "/bankmenu %s", actionId }
								})
							end
							if imgui.Button(u8('???????? ????????'), imgui.ImVec2(-1, 30)) then
								go_credit.v = false
								sampSendChat("/me {sex:???????|????????} ????? ? ???????? ?????")
							end
						imgui.EndChild()
					end
				end
				if TypeAction.v == 2 then
					imgui.CenterTextColoredRGB(mc..'???????????? ????????:')
					imgui.CenterTextColoredRGB('? 3 ???? ?????????? ? ????? (3+ ???)')
					imgui.CenterTextColoredRGB('? 35 ? ????? ?????????????????')
					imgui.CenterTextColoredRGB('? ?????????? ?????????? ? ?????????')
					imgui.CenterTextColoredRGB('? ?????????? ????????????????')
					imgui.CenterTextColoredRGB('? ?????????? ?????????')
					imgui.NewLine()
					if imgui.Button(u8('???????????'), imgui.ImVec2(-1, 30)) then
						play_message(MsgDelay.v, false, {
							{ "????????????, ? %s - {my_name}", cfg.nameRank[cfg.main.rank] },
							{ "?? ?? ??????????????" }
						})
					end
					if imgui.Button(u8('???????'), imgui.ImVec2(88, 30)) then
						play_message(MsgDelay.v, false, {
							{ "?????? ?????, ???????? ??? ???????" },
							{ "/b /showpass %s + 1-2 ?????????", selfid }
						})
					end
					imgui.SameLine()
					if imgui.Button(u8('???. ?????'), imgui.ImVec2(88, 30)) then
						play_message(MsgDelay.v, false, {
							{ "??????? ? ???????, ?????? ????? ???? ???-??????" },
							{ "/b /showmc %s + 1-2 ?????????", selfid }
						})
					end
					imgui.SameLine()
					if imgui.Button(u8('????????'), imgui.ImVec2(-1, 30)) then
						play_message(MsgDelay.v, false, {
							{ "???????, ???????? ??????? ???? ????????. ????????? ??? ??" },
							{ "/b /showlic %s + 1-2 ?????????", selfid }
						})
					end
					if question.v == 1 then 
						if imgui.Button(u8('????-????? [?????? ?1]'), imgui.ImVec2(-1, 30)) then
							question.v = 2
							play_message(MsgDelay.v, false, {
								{ "???, ?????? ???? ?????????? ??? ???.." },
								{ "?????? ?? ????????? ???? ??????????? ??????????? ?? ???????" }
							})
						end
					elseif question.v == 2 then 
						if imgui.Button(u8('????-????? [?????? ?2]'), imgui.ImVec2(-1, 30)) then
							question.v = 3
							play_message(MsgDelay.v, false, {
								{ "??? ????? ?????????? ???????? ? ????? ????????????" }
							})
						end
					elseif question.v == 3 then 
						if imgui.Button(u8('????-????? [?????? ?3]'), imgui.ImVec2(-1, 30)) then
							question.v = 1
							addBankMessage('??????? ?????????! ????? ????????? ?????!')
							play_message(MsgDelay.v, false, {
								{ "?? ????? ????????? ?????????? ????? ? ????" }
							})
						end
					end
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
					if imgui.Button(u8('??????? ')..fa.ICON_FA_USER_PLUS, imgui.ImVec2(135, 30)) then
						if not isPlayerOnBlacklist(sampGetPlayerNickname(actionId)) then 
							question.v = 1
							int_bank.v = false
							if cfg.main.rank >= 9 then
								play_message(MsgDelay.v, true, {
									{ "??????????! ?? ??? ?????????!" },
									{ "/me {sex:???????|????????} ????? ??????? ??? %s", rpNick(actionId) },
									{ "/invite %s", actionId },
									{ "?????? ????????????? ? ???????? ????????!" }
								})
							else
								local result, kassa = getNumberOfKassa()
								play_message(MsgDelay.v, true, {
									{ "??????????! ?? ??? ?????????!" },
									{ "?????? ? ?????? ?????????, ??? ?? ?? ??? ??????! ???? ??????????.." },
									{ 	(result 
										and 
										"/r ????? ??????? ?? ????? ?%s, ????? ??????? ???????? ?????????? ?????????????" 
										or
										"/r ????? ??????? ?? ???, ???-?? ??????? ???????? ?????????? ?????????????"), kassa 
									},
									{ "?????? ????????????? ? ???????? ????????!" }
								})
							end
						else
							addBankMessage('?? ?? ?????? ??????? ????? ?????? ?? ???????!')
							addBankMessage(string.format('????? {M}%s{W} ????????? ? {FF0000}?????? ??????{W}!', rpNick(actionId)))
						end
					end
					imgui.PopStyleColor(2)
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
					if imgui.Button(u8('????????? ')..fa.ICON_FA_USER_TIMES, imgui.ImVec2(-1, 30)) then
						imgui.OpenPopup(u8("??????? ??????????"))
						question.v = 1
					end
					imgui.PopStyleColor(2)
					if imgui.BeginPopupModal(u8("??????? ??????????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
						imgui.CenterTextColoredRGB(mc..'??????? ??????? ??????????')
						if imgui.Button(u8('???????? ? ???????? (NicName)'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ? ??? ???????? ? ????????" },
								{ "/b ????? ???????" },
								{ "????????? ??? ????????????? ? ????????? ???!" }
							})
						end
						if imgui.Button(u8('???? ??? ? ?????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ?????????? ???? ??? ? ?????" },
								{ "/b ????? 3+ ??????? ?????????" },
								{ "????????? ? ?????? ???!" }
							})
						end
						if imgui.Button(u8('????????????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ??? ?????????????" },
								{ "????????? ? ????????? ??? ???!" }
							})
						end
						if imgui.Button(u8('????? ?????????????????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ?? ??????????????" },
								{ "/b 35+ ????????????????? - /showpass %s", actionId },
								{ "????????? ? ?????? ???!" }
							})
						end
						if imgui.Button(u8('????????????????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ????????????" },
								{ "/b ???????? 3 ???????????????? - /showmc %s", actionId },
								{ "?????????? ? ????????? ??? ???!" }
							})
						end
						if imgui.Button(u8('??????????? ??????????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ?????????? ?? ??????" },
								{ "/b ??????? ??????????, ???????? ???. ????? - /showpass %s", actionId },
								{ "??????? ?? ???. ?????? ? ????????? ??? ???!" }
							})
						end
						if imgui.Button(u8('??????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
							play_message(MsgDelay.v, false, {
								{ "? ?????????, ?? ?? ?????????, ?? ???????" },
								{ "/b ??? ?????????? / ???? ? RP ???" },
								{ "????????? ? ????????? ??? ???!" }
							})
						end
						if imgui.Button(u8('????? ??????? ???????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
							int_bank.v = false
						end
						if imgui.MainButton(u8('?????'), imgui.ImVec2(250, 30)) then
							imgui.CloseCurrentPopup()
						end
						imgui.EndPopup()
					end
				end
				if TypeAction.v == 3 then
					imgui.CenterTextColoredRGB(mc..'???????? ???? ??????? ???????')
					imgui.CenterTextColoredRGB(sc..'??????? ????? ??????? ?????????????\n'..sc..'?? ???????? ? ??????? "????????"\n'..sc..'?? ?????? ???????!')
					imgui.NewLine()

					imgui.SetCursorPosX(33)
					for i = 1, 9 do
						imgui.TextDisabled(tostring(i))
						if i ~= 9 then
							imgui.SameLine(nil, 20)
						end
					end

					imgui.SetCursorPosX(28)
					for i = 1, 9 do
						imgui.RadioButton(u8("##giverank" .. i), giverank, i); imgui.Hint('ranknamegive'..i, u8(cfg.nameRank[i]))
						if i ~= 9 then
							imgui.SameLine()
						end
					end

					imgui.NewLine()
					imgui.SetCursorPosX(80)
					if imgui.Checkbox(u8'? ?? ??????????', upWithRp) then 
						cfg.main.upWithRp = upWithRp.v
					end

					imgui.NewLine()
					if imgui.MainButton(u8('???????? ')..fa.ICON_FA_SORT_NUMERIC_UP, imgui.ImVec2(-1, 40)) then
						if upWithRp.v then 
							int_bank.v = false
							play_message(MsgDelay.v, true, {
								{ "/me {sex:??????|???????} ?? ??????? ???" },
								{ "/me {sex:???????|????????} ??? ? {sex:?????|?????} ? ?????? ????????????" },
								{ "/me {sex:??????|???????} ?????????? %s", rpNick(actionId) },
								{ "/me {sex:???????|????????} ????????? ?????????? ?? %s", cfg.nameRank[giverank.v] },
								{ "/giverank %s %s", actionId, giverank.v }
							})
						else
							int_bank.v = false
							play_message(MsgDelay.v, true, {
								{ "/giverank %s %s", actionId, giverank.v }
							})
						end
					end
					if imgui.Button(u8('???????? ')..fa.ICON_FA_SORT_NUMERIC_DOWN, imgui.ImVec2(-1, -1)) then
						if upWithRp.v then 
							int_bank.v = false
							play_message(MsgDelay.v, true, {
								{ "/me {sex:??????|???????} ?? ??????? ???" },
								{ "/me {sex:???????|????????} ??? ? ????? ? ?????? ????????????" },
								{ "/me {sex:??????|???????} ?????????? %s", rpNick(actionId) },
								{ "/me {sex:???????|????????} ????????? ?????????? ?? %s", cfg.nameRank[giverank.v] },
								{ "/giverank %s %s", actionId, giverank.v }
							})
						else
							int_bank.v = false
							play_message(MsgDelay.v, true, {
								{ "/giverank %s %s", actionId, giverank.v }
							})
						end
					end
				end
			if TypeAction.v == 2 or TypeAction.v == 3 then
				imgui.EndChild()
			end
				imgui.SetCursorPos(imgui.ImVec2(10, 200))
				imgui.RadioButton(u8("?????????? ??????"), TypeAction, 1)
				imgui.SetCursorPos(imgui.ImVec2(10, 230))
				if cfg.main.rank > 4 then
					imgui.RadioButton(u8("?????????????"), TypeAction, 2)
				else
					imgui.RadioButton(u8("????????????? ")..fa.ICON_FA_LOCK, false)
					imgui.Hint('sobesmenu5rank', u8'???????? ? 5+ ?????')
				end
				imgui.SetCursorPos(imgui.ImVec2(10, 260))
				if cfg.main.rank > 8 then
					imgui.RadioButton(u8("?????????"), TypeAction, 3)
				else
					imgui.RadioButton(u8("????????? ")..fa.ICON_FA_LOCK, false)
					imgui.Hint('uprankmenu9+', u8'???????? ? 9+ ?????')
				end
		imgui.End()
	end

	if bank.v then
		local _, selfid = sampGetPlayerIdByCharHandle(PLAYER_PED) 
		imgui.SetNextWindowPos(imgui.ImVec2(ex / 2, ey / 2), imgui.Cond.Appearing, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'##MainMenu', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize)
		
		imgui.BeginGroup()
			imgui.PushFont(font[35])
			imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], fa.ICON_FA_UNIVERSITY.. ' Central Bank')
			local len_title = imgui.CalcTextSize(fa.ICON_FA_UNIVERSITY.. ' Central Bank').x
			imgui.PopFont()

			imgui.PushFont(font[11])
			imgui.SetCursorPos( imgui.ImVec2(len_title + 15, 27) )
			imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1.0), 'v'..thisScript().version .. (devmode and ' (Dev)' or ''))
			imgui.PopFont()

			imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 30, 25))
			if imgui.CloseButton(7) then bank.v = false end

			imgui.SetCursorPos(imgui.ImVec2(imgui.GetWindowWidth() - 65, 16))
			imgui.PushFont(font[20])
			imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE)
			imgui.PopFont()
			if imgui.IsItemClicked() then
				imgui.OpenPopup(u8("??? ??????? ???????"))
			end
			helpCommands()
		imgui.EndGroup()
		imgui.BeginGroup()
			imgui.BeginGroup()
			imgui.BeginChild("##SelfInfo", imgui.ImVec2(180, 125), true, imgui.WindowFlags.NoScrollbar)
				local str_rank = cfg.nameRank[cfg.main.rank]
				if #str_rank > 15 then
					local word = str_rank:match('[^%s]+$')
					str_rank = str_rank:gsub(word, '\n' .. sc .. word)
					imgui.SetCursorPosY(15)
				else
					imgui.SetCursorPosY(25)
				end
				imgui.PushFont(font[45])
				imgui.CenterText(fa.ICON_FA_USER_CIRCLE, imgui.GetStyle().Colors[imgui.Col.ButtonHovered])
				imgui.PopFont()
				imgui.PushFont(font[15])
				imgui.CenterTextColoredRGB(sc .. str_rank .. ' (' .. cfg.main.rank .. ')')
				imgui.PopFont()
				if imgui.IsItemClicked() then
					await['get_rank'] = os.clock()
					await['rank_update'] = os.clock()
					sampSendChat('/stats')
				else
					imgui.Hint('updaterank', u8'???????, ???-?? ????????')
				end
				imgui.PushFont(font[11])
				if type(cfg.main.dateuprank) == 'string' then
					imgui.CenterText(u8(string.format('? %s', cfg.main.dateuprank)))
				else
					imgui.CenterText(u8(os.date('C %d.%m.%Y', cfg.main.dateuprank)))
				end
				imgui.PopFont()
				if imgui.IsItemClicked() then
					await['uprankdate'] = os.clock()
					sampSendChat('/jobprogress')
				else
					imgui.Hint('updateprogress', u8'???????, ???-?? ?????????????')
				end
			imgui.EndChild()

			if imgui.Button(u8('?????? ')..fa.ICON_FA_COMMENTS, imgui.ImVec2(180, 30)) then
				type_window.v = 1
			end
			if imgui.Button(u8('?????? ')..fa.ICON_FA_UNIVERSITY, imgui.ImVec2(180, 30)) then
				type_window.v = 2
			end
			if imgui.Button(u8('??????? ')..fa.ICON_FA_INFO_CIRCLE, imgui.ImVec2(180, 30)) then
				type_window.v = 3
			end
			if cfg.main.rank > 4 then
				if imgui.Button(u8('??. ?????? ')..fa.ICON_FA_USERS, imgui.ImVec2(180, 30)) then
					type_window.v = 4
				end
			end
			if imgui.Button(u8('????????? ')..fa.ICON_FA_COG, imgui.ImVec2(180, 30)) then
				type_window.v = 5
			end
		imgui.EndGroup()
		imgui.SameLine()
		imgui.BeginChild("##MenuActive", imgui.ImVec2(350, -1), true, imgui.WindowFlags.NoScrollbar)

		if type_window.v == 1 then -- ?????
			if #cfg.Binds_Name > 0 then
				imgui.CenterTextColoredRGB(mc..'???? ???????????????? ?????? {868686}(?)')
				imgui.Hint('binderBB', u8'?????? ????? "B" (????.) ???\n???????? ???????? ????? ????')
				imgui.Separator()
				for key_bind, name_bind in pairs(cfg.Binds_Name) do
					imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(2, 2))
					if imgui.Button(name_bind..'##'..key_bind, imgui.ImVec2(269, 30)) then
						play_bind(key_bind)
						bank.v = false
					end 
					imgui.SameLine()    
					if imgui.Button(fa.ICON_FA_PEN..'##'..key_bind, imgui.ImVec2(30, 30)) then
						EditOldBind = true
						getpos = key_bind
						binder_delay.v = cfg.Binds_Deleay[key_bind]
						local returnwrapped = tostring(cfg.Binds_Action[key_bind]):gsub('~', '\n')
						text_binder.v = returnwrapped
						binder_name.v = tostring(cfg.Binds_Name[key_bind])
						imgui.OpenPopup(u8("??????????????/???????? ?????"))
						binder_open = true
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_FA_TRASH..'##'..key_bind, imgui.ImVec2(30, 30)) then
						addBankMessage(string.format('???? {M}?%s?{W} ?????? ?? ?????? ??????!', u8:decode(cfg.Binds_Name[key_bind])))
						table.remove(cfg.Binds_Name, key_bind)
						table.remove(cfg.Binds_Action, key_bind)
						table.remove(cfg.Binds_Deleay, key_bind)
						inicfg.save(cfg, 'Bank_Config.ini')
					end
					imgui.PopStyleVar()
				end
				if imgui.MainButton(u8('??????? ????? ????'), imgui.ImVec2(-1, 30)) then
					imgui.OpenPopup(u8("??????????????/???????? ?????"))
					binder_delay.v = 2500
				end
			else
				imgui.SetCursorPosY(40)
				imgui.PushFont(font[45])
				imgui.CenterText(fa.ICON_FA_BOOKMARK, imgui.ImVec4(0.5, 0.5, 0.5, 0.7))
				imgui.PopFont()
				imgui.NewLine()
				imgui.CenterTextColoredRGB('????? ??? ?????? ? ????????? ??? ???? ? ???????!\n??? ?? ????????????? ???????:\n??? + Q (???????? ?? ??????)')
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 130) / 2)
				if imgui.Button(u8('??????? ???? ????!'), imgui.ImVec2(130, 30)) then
					imgui.OpenPopup(u8("??????????????/???????? ?????"))
					binder_open = true
				end
			end
			binder()
		end
		if type_window.v == 2 then -- ??????
			imgui.CenterTextColoredRGB(mc..'?????????? ?????? ??? ???????????')
			if imgui.MainButton(fa.ICON_FA_PLUS_CIRCLE .. u8' ????????', imgui.ImVec2(100, 20)) then
				lection_number = nil
				lect_edit_name.v = u8("")
				lect_edit_text.v = u8("")
				imgui.OpenPopup(u8("???????? ??????"))
			end
			imgui.SameLine()
			imgui.PushItemWidth(80)
			if imgui.DragInt('##LectDelay', LectDelay, 1, 1, 30, u8('%0.0f ?.')) then
				if LectDelay.v < 1 then LectDelay.v = 1 end
				if LectDelay.v > 30 then LectDelay.v = 30 end
			end
			imgui.Hint('delaylection', u8'???????? ????? ???????????')
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.RadioButton(u8("???"), typeLect, 1)
			imgui.SameLine()
			imgui.RadioButton(u8("/r"), typeLect, 2)
			imgui.SameLine()
			imgui.RadioButton(u8("/rb"), typeLect, 3)
			imgui.Separator()
			if #lections.data == 0 then
				imgui.SetCursorPosY(120)
				imgui.CenterTextColoredRGB(mc..'? ??? ??? ?? ????? ?????? :(')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.MainButton(u8'???????????? ??????????? ???????', imgui.ImVec2(250, 25)) then
					lections = lections_default
					local file = io.open(lect_path, "w")
					file:write(encodeJson(lections))
					file:close()
				end
			else
				for i, block in ipairs(lections.data) do
					local name = block.name
					local data = block.text
					--
					if lections.active.bool == true then
						if name == lections.active.name then
							if imgui.MainButton(fa.ICON_FA_PAUSE .. '##' .. u8(name), imgui.ImVec2(280, 25)) then
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle:terminate()
								lections.active.handle = nil
							end
						else
							imgui.DisableButton(u8(name), imgui.ImVec2(280, 25))
						end
						imgui.SameLine()
						imgui.DisableButton(fa.ICON_FA_PEN .. '##' .. u8(name), imgui.ImVec2(-1, 25))
					else
						if imgui.Button(u8(name), imgui.ImVec2(280, 25)) then
							lections.active.bool = true
							lections.active.name = name
							lections.active.handle = lua_thread.create(function()
								for i, line in ipairs(data) do
									if typeLect.v == 2 then
										sampProcessChatInput(string.format('/r %s', line))
									elseif typeLect.v == 3 then
										sampProcessChatInput(string.format('/rb %s', line))
									else
										sampProcessChatInput(string.format('%s', line))
									end
									if i ~= #data then
										wait(LectDelay.v * 1000)
									end
								end
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle = nil
							end)
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_FA_PEN .. '##' .. u8(name), imgui.ImVec2(-1, 25)) then
							lection_number = i
							lect_edit_name.v = u8(tostring(name))
							lect_edit_text.v = u8(tostring(table.concat(data, '\n')))
							imgui.OpenPopup(u8"???????? ??????")
						end
					end
				end
			end
			lection_editor()
		end
		if type_window.v == 3 then -- ???????
			imgui.CenterTextColoredRGB(mc..'?????????? ??? ???????????')
			imgui.NewLine()

			if imgui.Button(u8('????? ???????????? ????? ')..fa.ICON_FA_BOOK_OPEN, imgui.ImVec2(-1, 35)) then
				ustav_window.v = true
			end
			if imgui.Button(u8('?????? ??????? ????????? ')..fa.ICON_FA_SORT_AMOUNT_UP, imgui.ImVec2(-1, 35)) then
				imgui.OpenPopup(u8("?????? ??????? ?????????"))
			end
			system_uprank()
			if imgui.Button(u8('???????? ??????? ')..fa.ICON_FA_CLOCK, imgui.ImVec2(-1, 35)) then
				imgui.OpenPopup(u8("???????? ???????"))
			end
			system_cadr()
			if imgui.Button(u8('??????? ???????????? ')..fa.ICON_FA_CALENDAR_CHECK, imgui.ImVec2(-1, 35)) then
				imgui.OpenPopup(u8("??????? ????????????"))
			end
			system_credit()
			if imgui.Button(u8('???????????? ?????? ')..fa.ICON_FA_FLAG, imgui.ImVec2(-1, 35)) then
				imgui.OpenPopup(u8("???????????? ??????"))
			end
			post()
		end
		if type_window.v == 4 then -- ??. ??????
			if imgui.Button(u8('׸???? ?????? ????????????? ')..fa.ICON_FA_BAN, imgui.ImVec2(-1, 35)) then
				imgui.OpenPopup(u8("׸???? ?????? ?????????????"))
			end
			BlackListGui()
			if cfg.main.rank >= 9 then
				if imgui.Button(u8('??????????????? ????? ')..fa.ICON_FA_GLOBE, imgui.ImVec2(-1, 35)) then
					imgui.OpenPopup(u8("???????????? ??????????????? ?????"))
				end
			else
				imgui.DisableButton(u8('??????????????? ????? ')..fa.ICON_FA_LOCK, imgui.ImVec2(-1, 35))
				imgui.Hint('goswave8+', u8'???????? ? 9 ?????')
			end
			gov()
		end

		if type_window.v == 5 then -- ?????????
			imgui.CenterTextColoredRGB(mc..'????????? ???????')
			imgui.NewLine()
			if imgui.CollapsingHeader(u8("????? ?????????")) then
				imgui.PushItemWidth(80)
				if imgui.Checkbox(u8'????-???????? ??????????', loginupdate) then
					cfg.main.loginupdate = loginupdate.v 
					if inicfg.save(cfg, 'Bank_Config.ini') then
						addBankMessage(string.format('????-???????? ?????????? ??? ????? ? ???? {M}%s', (cfg.main.loginupdate and '????????' or '?????????')))
					end
				end
				if imgui.Checkbox(u8'???-???????????', chat_calc) then
					cfg.main.chat_calc = chat_calc.v 
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				imgui.SameLine()
				imgui.TextDisabled('(?)')
				imgui.Hint('chatcalc', u8'???? ? ???? ????? ???????? ??????, ?? ??? ??? ???????? ?????')
				imgui.PopItemWidth()
				if imgui.Checkbox(u8'?????????? ?? ?????', ki_stat) then
					if cfg.main.rank < 5 then 
						ki_stat.v = false
						addBankMessage('???????? ? 5 ?????!') 
					else
						addBankMessage(string.format('?????????? ?? ?????: {M}%s', (ki_stat.v and mc..'????????' or mc..'?????????')))
						cfg.main.ki_stat = ki_stat.v
						inicfg.save(cfg, 'Bank_Config.ini')
						if kassa['stat'].v then kassa['stat'].v = false end
					end
				end
				imgui.SameLine()
				imgui.TextDisabled('(?)')
				imgui.Hint('kippos', u8'?????? ????? ??????????? ???????? /kip')
			end
			if imgui.CollapsingHeader(u8("??????????? ????????? ? ????")) then
				if imgui.Checkbox(u8'????????? ? /expel', chat['expel']) then
					cfg.Chat.expel = chat['expel'].v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if imgui.Checkbox(u8'?????? ???????', chat['shtrafs']) then
					cfg.Chat.shtrafs = chat['shtrafs'].v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if imgui.Checkbox(u8'?????????? ????? ????????????', chat['incazna']) then
					cfg.Chat.incazna = chat['incazna'].v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if imgui.Checkbox(u8'???????? ???????????', chat['invite']) then
					cfg.Chat.invite = chat['invite'].v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if imgui.Checkbox(u8'?????????? ???????????', chat['uval']) then
					cfg.Chat.uval = chat['uval'].v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
			end
			if imgui.CollapsingHeader(u8("????????? ?????????/???????")) then
				imgui.TextColoredRGB(mc..'???????? ????? ??????????? ? ??????????:')
				imgui.PushItemWidth(200)
				if imgui.SliderFloat('##MsgDelay', MsgDelay, 0.5, 10.0, u8'%0.2f ?.') then
					if MsgDelay.v < 0.5 then MsgDelay.v = 0.5 end
					if MsgDelay.v > 10.0 then MsgDelay.v = 10.0 end
				end
				imgui.PopItemWidth()

				imgui.TextColoredRGB(mc..'??? ???:')
				imgui.SameLine()
				if imgui.SmallButton(u8'??????????') then 
					local aSex = autoGetSelfGender()
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage(string.format('??? ??? ????????? ??? {M}%s', (aSex == 1 and '???????' or '???????')))
					end
				end
				if imgui.RadioButton(u8("???????"), sex, 1) then
					cfg.main.sex = sex.v
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('??? ??????? ?? {M}???????')
					end
				end
				if imgui.RadioButton(u8("???????"), sex, 2) then 
					cfg.main.sex = sex.v
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('??? ??????? ?? {M}???????')
					end
				end

				imgui.TextColoredRGB(mc..'????-????? + /time {565656}(?)')
				imgui.Hint('autoscreen', u8'??? ???? ?????????, ??????????, ?????? ?????? ? ?.?.\n????? ????????????? ????????? ? /time')
				if imgui.Checkbox(u8(autoF8.v and '????????' or '?????????')..'##autoF8', autoF8) then 
					cfg.main.autoF8 = autoF8.v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if autoF8.v then
					if not doesFileExist(getGameDirectory()..'/Screenshot.asi') then
						if imgui.Button(u8'??????? Screenshot.asi', imgui.ImVec2(150, 20)) then 
							downloadUrlToFile('https://gitlab.com/uploads/-/system/personal_snippet/1978930/0b4025da038173a8b1ce81d5e3848901/Screenshot.asi', getGameDirectory()..'/Screenshot.asi', function (id, status, p1, p2)
								if status == dlstatus.STATUSEX_ENDDOWNLOAD then
									runSampfuncsConsoleCommand('pload Screenshot.asi')
									addBankMessage('?????? {M}Screenshot.asi{W} ????????! ????????????? ????????? ? ????!')
								end
							end)
						end
						imgui.Hint('screenplugin', u8('????????? ?????? ???????????? ????????? ??? ????????? ????\n????? ?????????? ????? ????????? ? ????\n?????: MISTER_GONWIK'), 0, u8'???????, ???-?? ???????')
					else
						imgui.TextColoredRGB('{30FF30}???????????? Screenshot.asi')
					end
				end

				imgui.TextColoredRGB(mc..'??????')
				if imgui.Checkbox(u8(accent_status.v and '????????' or '?????????')..'##accent_status', accent_status) then 
					cfg.main.accent_status = accent_status.v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if cfg.main.accent_status then
					imgui.PushItemWidth(280)
					imgui.InputText(u8"##accent", accent); imgui.SameLine()
					imgui.PopItemWidth()
					if imgui.Button('Save##accent', imgui.ImVec2(-1, 20)) then 
						cfg.main.accent = u8:decode(accent.v)
						if inicfg.save(cfg, 'Bank_Config.ini') then 
							addBankMessage('?????? ????????!')
						end
					end
				end
				imgui.TextColoredRGB(mc..'????-????????? ???????')
				if imgui.Checkbox(u8(rpbat.v and '????????' or '?????????')..'##rpbat', rpbat) then 
					cfg.main.rpbat = rpbat.v
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				if rpbat.v then
					imgui.TextColoredRGB(mc..'????? ???????')
					imgui.PushItemWidth(280)
					imgui.InputText(u8"##rpbat_true", rpbat_true); imgui.SameLine()
					imgui.PopItemWidth()
					if imgui.Button('Save##1', imgui.ImVec2(-1, 20)) then 
						cfg.main.rpbat_true = u8:decode(rpbat_true.v)
						if inicfg.save(cfg, 'Bank_Config.ini') then 
							addBankMessage('????????? ?????????!')
						end
					end

					imgui.TextColoredRGB(mc..'?????? ???????')
					imgui.PushItemWidth(280)
					imgui.InputText(u8"##rpbat_false", rpbat_false); imgui.SameLine()
					imgui.PopItemWidth()
					if imgui.Button('Save##2', imgui.ImVec2(-1, 20)) then 
						cfg.main.rpbat_false = u8:decode(rpbat_false.v)
						if inicfg.save(cfg, 'Bank_Config.ini') then 
							addBankMessage('????????? ?????????!')
						end
					end
				end
			end
			if imgui.CollapsingHeader(u8("????????? ??????")) then
				if imgui.ToggleButton(u8'Ҹ???? ????', black_theme) then
					SCRIPT_STYLE.clock = os.clock()
					cfg.main.black_theme = black_theme.v
					inicfg.save(cfg, 'Bank_Config.ini')
				end

				local duration = 1.0
				if SCRIPT_STYLE.clock ~= nil then
					local B = black_theme.v and imgui.ImVec4(0.10, 0.10, 0.11, 1.00) or imgui.ImVec4(0.95, 0.95, 0.95, 1.00)
					local E = black_theme.v and imgui.ImVec4(0.00, 0.40, 0.60, 1.00) or imgui.ImVec4(0.00, 0.40, 0.60, 1.00)
					local T = black_theme.v and imgui.ImVec4(1.00, 1.00, 1.00, 1.00) or imgui.ImVec4(0.20, 0.20, 0.20, 1.00)

					if os.clock() - SCRIPT_STYLE.clock <= duration then
						SCRIPT_STYLE.colors['B'] = degrade(SCRIPT_STYLE.colors['B'], B, SCRIPT_STYLE.clock, duration)
						SCRIPT_STYLE.colors['E'] = degrade(SCRIPT_STYLE.colors['E'], E, SCRIPT_STYLE.clock, duration)
						SCRIPT_STYLE.colors['T'] = degrade(SCRIPT_STYLE.colors['T'], T, SCRIPT_STYLE.clock, duration)
					else
						SCRIPT_STYLE.colors = { B = B, E = E, T = T }
						SCRIPT_STYLE.clock = nil
					end

					set_style(SCRIPT_STYLE.colors)
				end
			
				if imgui.ColorEdit4(u8'???? ???? ???????????', colorRchat, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(colorRchat.v[1], colorRchat.v[2], colorRchat.v[3], colorRchat.v[4]):GetU32()
					cfg.main.colorRchat = clr
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 150)
				if imgui.Button(u8("????##RCol"), imgui.ImVec2(50, 20)) then
					local r, g, b, a = imgui.ImColor(cfg.main.colorRchat):GetRGBA()
					sampAddChatMessage('[R] '..cfg.nameRank[cfg.main.rank]..' '..sampGetPlayerNickname(tonumber(selfid))..'['..selfid..']:(( ??? ????????? ?????? ?????? ??! ))', join_rgb(r, g, b))
				end
				imgui.SameLine(imgui.GetWindowWidth() - 95)
				if imgui.Button(u8("???????????##Rcol"), imgui.ImVec2(90, 20)) then
					cfg.main.colorRchat = 4282626093
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('??????????? ???? ???? ??????????? ????????????!')
						colorRchat = imgui.ImFloat4(imgui.ImColor(cfg.main.colorRchat):GetFloat4())
					end
				end

				if imgui.ColorEdit4(u8'???? ???? ????????????', colorDchat, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(colorDchat.v[1], colorDchat.v[2], colorDchat.v[3], colorDchat.v[4]):GetU32()
					cfg.main.colorDchat = clr
					inicfg.save(cfg, 'Bank_Config.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 150)
				if imgui.Button(u8("????##DCol"), imgui.ImVec2(50, 20)) then
					local r, g, b, a = imgui.ImColor(cfg.main.colorDchat):GetRGBA()
					sampAddChatMessage('[D] '..cfg.nameRank[cfg.main.rank]..' '..sampGetPlayerNickname(tonumber(selfid))..'['..selfid..']: ??? ????????? ?????? ?????? ??!', join_rgb(r, g, b))
				end
				imgui.SameLine(imgui.GetWindowWidth() - 95)
				if imgui.Button(u8("???????????##DCol"), imgui.ImVec2(90, 20)) then
					cfg.main.colorDchat = 4294940723
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('??????????? ???? ???? ???????????? ????????????!')
						colorDchat = imgui.ImFloat4(imgui.ImColor(cfg.main.colorDchat):GetFloat4())
					end
				end

				if bratishka then 
					if imgui.ColorEdit4(u8'???? ???? ? ???? ???', colorCosmo, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
						local clr = imgui.ImColor.FromFloat4(colorCosmo.v[1], colorCosmo.v[2], colorCosmo.v[3], colorCosmo.v[4]):GetU32()
						cfg.main.colorCosmo = clr
						inicfg.save(cfg, 'Bank_Config.ini')
					end
					imgui.SameLine()
					imgui.TextDisabled('(?)')
					imgui.Hint('colororgchat', u8'?????????? ???? ?????? ?????? ?????? ??!\n????????? ????? ?????? ????????? ????')
					imgui.SameLine(imgui.GetWindowWidth() - 150)
					if imgui.Button(u8("????##CosmoCol"), imgui.ImVec2(50, 20)) then
						local cr, cg, cb, ca = imgui.ImColor(cfg.main.colorCosmo):GetRGBA()
						local mr, mg, mb, ma = imgui.ImColor(cfg.main.colorRchat):GetRGBA()
						sampAddChatMessage(string.format('[R] '..cfg.nameRank[cfg.main.rank]..' {%06X}'..sampGetPlayerNickname(tonumber(selfid))..'['..selfid..']{%06X}:(( ??? ????????? ?????? ?????? ??! ))', join_rgb(cr, cg, cb), join_rgb(mr, mg, mb)), join_rgb(mr, mg, mb))
					end
					imgui.SameLine(imgui.GetWindowWidth() - 95)
					if imgui.Button(u8("???????????##CosmoCol"), imgui.ImVec2(90, 20)) then
						cfg.main.colorCosmo = 4294940979
						if inicfg.save(cfg, 'Bank_Config.ini') then 
							addBankMessage('??????????? ???? ???? ? ???? ???. ????????????!')
							colorCosmo = imgui.ImFloat4(imgui.ImColor(cfg.main.colorCosmo):GetFloat4())
						end
					end
				else
					imgui.ColorEdit4(u8'##???? ???? Disabled', colorCosmo, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoPicker + imgui.ColorEditFlags.NoTooltip)
					if imgui.IsItemClicked() then addBankMessage('??? ?? ???????? ??? ???????!') end
					imgui.SameLine(32)
					imgui.TextDisabled(u8('???? ???? ')..fa.ICON_FA_LOCK)
					imgui.Hint('colormynick', u8'??????? ???????? ????????????? ? ???????? Cosmo\n????????: Bob_Cosmo')
					imgui.SameLine(imgui.GetWindowWidth() - 150)
					imgui.DisableButton(u8"????##CosmoColDisabled", imgui.ImVec2(50, 20))
					imgui.SameLine(imgui.GetWindowWidth() - 95)
					imgui.DisableButton(u8"???????????##CosmoColDisabled", imgui.ImVec2(90, 20))
				end
			end
			if imgui.CollapsingHeader(u8("????????? ????")) then
				imgui.TextColoredRGB('{868686}(?????????)')
				imgui.Hint('setform', u8'??? ?? ?? ?????? ??????? ??????? ?????\n?????????? ? ?????? ???? ???????? ???????? !????\n? ?????? ??? ?? ??? ??????? ? ?????? ???? ????? ???????')
				imgui.PushItemWidth(280)
				imgui.TextColoredRGB(mc..'????? ????? '..'{SSSSSS}'..'(!????):')
				imgui.InputText('##forma_post', forma_post)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button('Save##3', imgui.ImVec2(-1, 20)) then 
					cfg.main.forma_post = u8:decode(forma_post.v)
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('????? ?????????!')
					end
				end
				imgui.PushItemWidth(280)
				imgui.TextColoredRGB(mc..'????? ?????? ?????? '..'{SSSSSS}'..'(!??????):')
				imgui.InputText('##forma_lect', forma_lect)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button('Save##4', imgui.ImVec2(-1, 20)) then 
					cfg.main.forma_lect = u8:decode(forma_lect.v)
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('????? ?????????!')
					end
				end
				imgui.PushItemWidth(280)
				imgui.TextColoredRGB(mc..'????? ?????? ?????????? '..'{SSSSSS}'..'(!?????):')
				imgui.InputText('##forma_tr', forma_tr)
				imgui.PopItemWidth()
				imgui.SameLine()
				if imgui.Button('Save##5', imgui.ImVec2(-1, 20)) then 
					cfg.main.forma_tr = u8:decode(forma_tr.v)
					if inicfg.save(cfg, 'Bank_Config.ini') then 
						addBankMessage('????? ?????????!')
					end
				end
			end
			if imgui.CollapsingHeader(u8("? ???????")) then
				imgui.NewLine()
				imgui.CenterTextColoredRGB('????? ???????: ' .. mc..'Cosmo')
				imgui.CenterTextColoredRGB('{868686}????? ?????? ??? ???? ???????????? ?????? ????:')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 280) / 2)
				imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 5)
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0, 0.45, 0.8, 0.8))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0, 0.45, 0.8, 0.9))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0, 0.45, 0.8, 1))
				imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
				if imgui.Button(fa.ICON_FA_LINK..u8(" ?????????"), imgui.ImVec2(90, 25)) then
					addBankMessage('?????? ??????????? ? ????? ??????')
					setClipboardText("https://vk.com/opasanya")
				end
				imgui.PopStyleColor(4)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.41, 0.19, 0.63, 0.8))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.41, 0.19, 0.63, 0.9))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.41, 0.19, 0.63, 1))
				if imgui.Button(fa.ICON_FA_LINK..u8(" Discord"), imgui.ImVec2(90, 25)) then
					addBankMessage('?????? ??????????? ? ????? ??????')
					setClipboardText("cosmo#2362")
				end
				imgui.PopStyleColor(3)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.23, 0.36, 1.0))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.33, 0.46, 1.0))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.43, 0.56, 1.0))
				if imgui.Button(fa.ICON_FA_LINK..u8(" Blast Hack"), imgui.ImVec2(90, 25)) then
					addBankMessage('?????? ??????????? ? ????? ??????')
					setClipboardText("https://www.blast.hk/threads/58083/")
				end
				imgui.PopStyleColor(3)
				imgui.PopStyleVar()

				imgui.SetCursorPosX((imgui.GetWindowWidth() - 150) / 2)
				if imgui.RedButton(u8'??????? Bank-Helper', imgui.ImVec2(150, 20)) then
					imgui.OpenPopup('##deleteBankHelper')
				end

				imgui.SetNextWindowSize(imgui.ImVec2(400, -1), imgui.Cond.FirstUseEver)
				imgui.PushStyleColor(imgui.Col.ModalWindowDarkening, imgui.ImVec4(0.70, 0.00, 0.00, 0.10))
				if imgui.BeginPopupModal('##deleteBankHelper', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoTitleBar) then

					imgui.PushFont(font[20])
					imgui.CenterText(fa.ICON_FA_TRASH, imgui.ImVec4(0.8, 0.3, 0.3, 1.0))
					imgui.CenterText(u8'???????? BANK HELPER', imgui.ImVec4(0.8, 0.3, 0.3, 1.0))
					imgui.PopFont()
					imgui.Spacing()
					imgui.CenterText(u8'?? ????????????? ?????? ??????? Bank-Helper?')
					imgui.CenterText(u8'???????? ??? ???????? ????? ??????????!', imgui.ImVec4(0.8, 0.3, 0.3, 1.0))
					imgui.Spacing()

					imgui.SetCursorPosX((imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2)
					if imgui.RedButton(u8'???????', imgui.ImVec2(150, 30)) then
						addBankMessage('?????? :(')
						os.remove(thisScript().path)
						os.remove(getWorkingDirectory() .. '\\config\\Bank_Config.ini')
						unload(false)
					end
					imgui.SameLine()
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.20, 0.20, 0.20, 1.00))
					if imgui.Button(u8'?????????', imgui.ImVec2(150, 30)) then
						imgui.CloseCurrentPopup()
					end
					imgui.PopStyleColor()

					imgui.EndPopup()
				end
				imgui.PopStyleColor()
				imgui.NewLine()
			end

			if imgui.Button(u8('??????????? ')..fa.ICON_FA_PUZZLE_PIECE, imgui.ImVec2(imgui.GetWindowWidth() / 2 - 12, 30)) then
				type_window.v = 6
			end
			imgui.SameLine()
			if imgui.Button(u8('????????? ?????????? ')..fa.ICON_FA_DOWNLOAD, imgui.ImVec2(imgui.GetWindowWidth() / 2 - 12, 30)) then
				autoupdate(jsn_upd); checkData()
			end

			if imgui.GreenButton(u8'?????? ?????????', imgui.ImVec2(-1, 30)) then
				infoupdate.v = true
			end
		end

		if type_window.v == 6 then 
			imgui.CenterTextColoredRGB(mc..'??????????? ???????? ???????? {868686}(?)')
			imgui.Hint('aboutrepository', u8'??? ??????? ??????? ????? ??????? ?????\n????-??????? ? ?? ????? ? ???? ?????????.')
			imgui.Separator()
			imgui.Repository('OnScreenMembers (OSM)', 'OnScreenMembers.lua', '??????, ??????? ????? ??????? ???? /members\n??????????? ?? ??? ?????, ?????? ???????? ???? ??? ?????????????\n? ??? ?? ??????? ??????????? ???????????', '/osm', 'https://gitlab.com/uploads/-/system/personal_snippet/1978930/ec1816d3e019ad5e7a06283ec6308d19/OnScreenMembers.lua', 'https://www.blast.hk/threads/59761/')
			imgui.Repository('Timer Online', 'TimerOnline.lua', '??????, ??????? ??????? ??? ?????? ? ????.\n????? ??????? ?????? ??????, ?????? ? ???,\n? ??? ?? ?????? ?? ???? ? ?? ??????', '/toset', 'https://gitlab.com/uploads/-/system/personal_snippet/1978930/0e7c0070d9207abd5063ddbf2cd1cf59/TimerOnline.lua', 'https://www.blast.hk/threads/59396/')
			imgui.Repository('Leader Logger', 'LeadLogger.lua', '?????? ??????? ????? ?????????? ??? ????????? ???????? ? ??????????? ????? ??? ?????????, ??????????, ???????, ???????? ? ??? ?????. ????? ??????? ??????? ??? ??????????? ??????? ?? ?????', '/logger', 'https://gitlab.com/uploads/-/system/personal_snippet/1978930/26668c363e85f146567d4e0cfa4e08ae/LeadLogger.lua', 'https://www.blast.hk/threads/59244/')
			imgui.Repository('Chat Clist', 'cnickchat.lua', '??? ????????? ???? ??????? ? ???? ????? ?????? ?? ??????', '?????????????', 'https://gitlab.com/uploads/-/system/personal_snippet/1978930/28975bb7431741f67540db5406ca0bf8/cnickchat.lua')
			imgui.Repository('Premium', 'Premium.lua', '??????????? ? ??????? ???? ?????? ?????? ???????????', '/prem', 'https://gitlab.com/uploads/-/system/personal_snippet/1978930/a73761a36dc0e6c4eb8277a7639c947c/Premium.lua')
		end
		imgui.EndChild()
		imgui.EndGroup()
		imgui.End()
	end

	if ustav_window.v then
		local xx, yy = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(xx / 1.5, yy / 1.5), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(xx / 2, yy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'????? ???????????? ?????', ustav_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
			
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			imgui.PushItemWidth(200)
			imgui.PushAllowKeyboardFocus(false)
			imgui.InputText("##search_ustav", search_ustav, imgui.InputTextFlags.EnterReturnsTrue)
			imgui.PopAllowKeyboardFocus()
			imgui.PopItemWidth()
			if not imgui.IsItemActive() and #search_ustav.v == 0 then
				imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' ????? ?? ??????')).x) / 2)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' ????? ?? ??????'))
			end
			imgui.CenterTextColoredRGB('{868686}??????? ???? ?? ??????, ??????? ?? ? ???? ????? ? ????')
			imgui.Separator()
			local ustav = io.open("moonloader/BHelper/????? ??.txt", "r+")
			for line in ustav:lines() do
				if #line == 0 then line = ' ' end
				if #search_ustav.v < 1 then
					imgui.TextColoredRGB(line)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line)
					end
				else
					line = imgui.MarkTextByPart(u8:decode(search_ustav.v), line)
					imgui.TextColoredRGB(line)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line)
					end
				end
			end
			ustav:close()

			local wsize = imgui.GetWindowSize()
			imgui.SetCursorPos(imgui.ImVec2(wsize.x - 30, 30))
			if imgui.Button(fa.ICON_FA_PEN .. '##ustavedit', imgui.ImVec2(20, 20)) then
				os.execute('explorer '..getWorkingDirectory()..'\\BHelper\\????? ??.txt')
			end
		imgui.End()
	end
	Window_Info_Update()
	GetKassaInfo()
	GlobalNotify()
end

function imgui.MarkTextByPart(search, str, color)
    local _, r, g, b = explode_argb(color or 0xFFFF0000)
    local hex = ('{%06X}'):format(join_rgb(r, g, b))
    search = search:gsub('[%(%)%.%%%+%-%*%?%[%]%^%$]', '%%%1')
    return str:gsub(search, hex .. '%1{SSSSSS}')
end

function GlobalNotify()
	notify.active = 0
	for k, v in ipairs(notify.messages) do
		local push = false
		if v.active and v.time < os.clock() then
			v.active = false
		end

		if notify.active < notify.max then
			if not v.active then
				if v.showtime > 0 then
					v.active = true
					v.time = os.clock() + v.showtime
					v.showtime = 0
				end
			end
			if v.active then
				notify.active = notify.active + 1
				if v.time + 3.000 >= os.clock() then
					imgui.PushStyleVar(imgui.StyleVar.Alpha, (v.time - os.clock()) / 1.0)
					push = true
				end
				notify.list.pos = imgui.ImVec2(notify.list.pos.x, notify.list.pos.y - 80)

				imgui.SetNextWindowPos(notify.list.pos, _, imgui.ImVec2(0.0, 0.25))
				imgui.SetNextWindowSize(imgui.ImVec2(250, 70))
				imgui.PushStyleVar(imgui.StyleVar.WindowRounding, 5.0)
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0.0, 0.0))
				imgui.PushStyleVar(imgui.StyleVar.ChildWindowRounding, 5.0)
				imgui.Begin(u8'##notifycard'..k, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar)
					
					local p = imgui.GetCursorScreenPos()
					local ws = imgui.GetWindowSize()
					local bar_size = (v.bar_time - (os.clock() - v.start)) / ( v.bar_time / ws.x )
					if bar_size > 0 then
						imgui.GetWindowDrawList():AddRectFilled(
							imgui.ImVec2(p.x, p.y + (ws.y - 5)), 
							imgui.ImVec2(p.x + bar_size, p.y + ws.y), 
							imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.5, 1.0, (v.time - os.clock()) / 1.0)), 
							5, 
							bar_size == ws.x and 12 or 8
						)
					end
					imgui.SetCursorPos(imgui.ImVec2(5, 5))
					imgui.BeginGroup()
						imgui.PushFont(font[60])
						imgui.TextColored(imgui.ImVec4(0.0, 0.41, 0.76, 1.00), fa.ICON_FA_UNIVERSITY)
						imgui.PopFont()
					imgui.EndGroup()
					imgui.SameLine(nil, 10)
					imgui.BeginGroup()
						imgui.SetCursorPosY(7.5)
						imgui.PushFont(font[15])
						imgui.TextColoredRGB('{006AC2}Central Bank')
						imgui.PopFont()
						imgui.TextColoredRGB(tostring(v.text))
					imgui.EndGroup()
				imgui.End()
				imgui.PopStyleVar(3)
				if push then
					imgui.PopStyleVar()
				end
			end
		end
	end
	notf_sX, notf_sY = convertGameScreenCoordsToWindowScreenCoords(605, 438)
	notify.list = {
		pos = { x = notf_sX - 200, y = notf_sY + 20 },
		npos = { x = notf_sX - 200, y = notf_sY },
		size = { x = 200, y = 0 }
	}
end

function addNotify(text, time)
	notify.messages[#notify.messages + 1] = { 
		active = false, 
		time = 0, 
		showtime = time,
		text = text,
		start = os.clock(),
		bar_time = time - 1
	}
end

function GetKassaInfo()
	if kassa['stat'].v then
		imgui.SetNextWindowPos(imgui.ImVec2(cfg.main.KipX, cfg.main.KipY), imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(210, 140), imgui.Cond.FirstUseEver)
		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
		imgui.Begin(u8("??????????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar)

			local p = imgui.GetCursorScreenPos()
			local ws = imgui.GetWindowSize()
			imgui.GetWindowDrawList():AddRectFilled(
				imgui.ImVec2(p.x + (ws.x - 6), p.y), 
				imgui.ImVec2(p.x + ws.x, p.y + ws.y), 
				imgui.ColorConvertFloat4ToU32(imgui.ImVec4(0.0, 0.5, 1.0, 1.00)), 
				imgui.GetStyle().FrameRounding, 
				6
			)
			imgui.SetCursorPos(imgui.ImVec2(8, 8))
			imgui.BeginGroup()
				local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
				local distBetweenKassa = getDistanceBetweenCoords3d(kassa['pos'].x, kassa['pos'].y, kassa['pos'].z, myX, myY, myZ)
				if distBetweenKassa < 10 then
					imgui.CenterTextColoredRGB(sc..'????: '..kassa['name'].v:gsub('\n', ''))
					imgui.Text(fa.ICON_FA_CLOCK);           imgui.SameLine(30); imgui.TextColoredRGB(mc..'????? ?? ?????: {SSSSSS}'         ..kassa['time'].v..' ???.')
					imgui.Text(fa.ICON_FA_CHECK_CIRCLE);    imgui.SameLine(30); imgui.TextColoredRGB(mc..'????????? ?????????: {SSSSSS}'    ..tostring(cfg.kassa.dep))
					imgui.Text(fa.ICON_FA_HANDSHAKE);       imgui.SameLine(30); imgui.TextColoredRGB(mc..'????????? ????????: {SSSSSS}'     ..tostring(cfg.kassa.credit))
					imgui.Text(fa.ICON_FA_CREDIT_CARD);     imgui.SameLine(30); imgui.TextColoredRGB(mc..'?????? ????: {SSSSSS}'            ..tostring(cfg.kassa.card))
					imgui.Text(fa.ICON_FA_RECYCLE);         imgui.SameLine(30); imgui.TextColoredRGB(mc..'????????????? ????: {SSSSSS}'     ..tostring(cfg.kassa.recard))
					imgui.Text(fa.ICON_FA_PIGGY_BANK);      imgui.SameLine(30); imgui.TextColoredRGB(mc..'??????????: {SSSSSS}'             ..kassa['money']..'$')
				else
					imgui.CenterTextColoredRGB(sc..'????: '..kassa['name'].v:gsub('\n', ''))
					imgui.SetCursorPosY(50)
					imgui.CenterTextColoredRGB(mc..'?? ?????? ??????!\n????????? ????? ? ?????!\n{SSSSSS}'..math.floor(distBetweenKassa)..'?. ?? ?????')
				end
			imgui.EndGroup()
		imgui.End()
		imgui.PopStyleVar()
	end
end

function lection_editor(lection)
	if imgui.BeginPopupModal(u8"???????? ??????", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then

		imgui.InputText(u8"???????? ??????##lecteditor", lect_edit_name)
		if lection_number ~= nil then
			imgui.SameLine(600)
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
			if imgui.Button(u8('??????? ')..fa.ICON_FA_TRASH, imgui.ImVec2(-1, 20)) then
				imgui.CloseCurrentPopup()
				table.remove(lections.data, lection_number)
				local file = io.open(lect_path, "w")
				file:write(encodeJson(lections))
				file:close()
			end
			imgui.PopStyleColor(2)
		end
		imgui.InputTextMultiline("##lecteditortext", lect_edit_text, imgui.ImVec2(700, 300))

		imgui.SetCursorPosX( (imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2 )
		if #lect_edit_name.v > 0 and #lect_edit_text.v > 0 then
			if imgui.MainButton(u8"?????????##lecteditor", imgui.ImVec2(150, 20)) then
				local pack = function(text, match)
					local array = {}
					for line in text:gmatch('[^' .. match .. ']+') do
						array[#array + 1] = line
					end
					return array
				end
				if lection_number == nil then 
					table.insert(lections.data, {
						name = u8:decode(tostring(lect_edit_name.v)),
						text = pack(u8:decode(tostring(lect_edit_text.v)), '\n')
					})
				else
					lections.data[lection_number].name = u8:decode(tostring(lect_edit_name.v))
					lections.data[lection_number].text = pack(u8:decode(tostring(lect_edit_text.v)), '\n')
				end
				
				local file = io.open(lect_path, "w")
				file:write(encodeJson(lections))
				file:close()
				imgui.CloseCurrentPopup()
			end
		else
			imgui.DisableButton(u8"?????????##lecteditor", imgui.ImVec2(150, 20))
			imgui.Hint('errgraflection', u8'????????? ?? ??? ????!')
		end
		imgui.SameLine()
		if imgui.Button(u8"????????##lecteditor", imgui.ImVec2(150, 20)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function go_expel(playerId)
	local self_color = sampGetPlayerColor(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
	local target_color = sampGetPlayerColor(playerId)
	if target_color ~= self_color then
		if not sampIsPlayerPaused(playerId) then
			play_message(MsgDelay.v, true, {
				{ "??? ???????? ??????? ??? ?? ?????? ?????." },
				{ "/me {sex:???????|????????} ?? ???? %s ? {sex:?????|??????} ? ??????", rpNick(playerId) },
				{ "/todo ? ?????? ????????? ??? ????? ??????????!*???????? ????? ?????.." },
				{ "/expel %s %s", playerId, u8:decode(expelReason.v) }
			})
		else
			addBankMessage('?????? ??????? ?????? ??????? ? ???!')
		end
	else
		addBankMessage('??????, ?? ????????? ??????? ?????????? ?????...')
	end
end

function onWindowMessage(msg, wparam, lparam)
	if wparam == 0x1B then -- ESC
		if int_bank.v then
			consumeWindowMessage(true, true)
			int_bank.v = false
		end
		if ustav_window.v then
			consumeWindowMessage(true, true)
		end
	end
end

function imgui.Hint(str_id, hint, delay)
	local hovered = imgui.IsItemHovered()
	local animTime = 0.2
	local delay = delay or 0.00
	local show = true

	if not allHints then allHints = {} end
	if not allHints[str_id] then
		allHints[str_id] = {
			status = false,
			timer = 0
		}
	end

	if hovered then
		for k, v in pairs(allHints) do
			if k ~= str_id and os.clock() - v.timer <= animTime  then
				show = false
			end
		end
	end

	if show and allHints[str_id].status ~= hovered then
		allHints[str_id].status = hovered
		allHints[str_id].timer = os.clock() + (hovered and delay or 0.00)
	end

	local getContrastColor = function(col)
	    local luminance = 1 - (0.299 * col.x + 0.587 * col.y + 0.114 * col.z)
	    return luminance < 0.5 and imgui.ImVec4(0, 0, 0, 1) or imgui.ImVec4(1, 1, 1, 1)
	end

	local bg_col = imgui.GetStyle().Colors[imgui.Col.Button]
	local t_col = getContrastColor(bg_col)

	imgui.PushStyleColor(imgui.Col.PopupBg, bg_col)
	imgui.PushStyleColor(imgui.Col.Text, t_col)
	if show then
		local between = os.clock() - allHints[str_id].timer
		if between <= animTime then
			local s = function(f) 
				return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
			end
			local alpha = hovered and s(between / animTime) or s(1.00 - between / animTime)
			imgui.PushStyleVar(imgui.StyleVar.Alpha, alpha)
			imgui.SetTooltip(hint)
			imgui.PopStyleVar()
		elseif hovered then
			imgui.SetTooltip(hint)
		end
	end
	imgui.PopStyleColor(2)
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if marker then deleteCheckpoint(marker) end
		if checkpoing then removeBlip(checkpoint) end

		if not sampIsDialogActive() then
			showCursor(false, false)
		end
		if inicfg.save(cfg, 'Bank_Config.ini') then 
			log('??? ????????? ?????????!')
		end
		if not noErrorDialog and not devmode then
			sampShowDialog(1313, "{006AC2}[ Bank ] ?????? ???????? ???? ??????", [[
{006AC2}                                                           ??? ?????? ???? ?? ???????? ???????{FFC973}

1. ?????? ?????? ???? ?????????? ?????? ?? ??????????.
 - ???? ???? ? ??? ????? ???? ??????????? ?????-?? ????? ?? ?????? ?? ??????????? ????????.

2. ???? ?? ?????????? ? ????????? ?????? ???????, ?? ?????? ????? ?? ?????? ??????
 ?????? ??? ??????????. ?? ??? ???? ????????? ?????? CTRL + R, ? 90 ????????? ???????
 ??? ????????

3. ???? ? ??? ?????????? MVD Helper, ?? ??? ????? ??? ???????, ?? ?????????? ??????
 ?????? MonnLoader 0.25, ? ?????? ?????? ???????? ?? ????????? ?????????? ?????? 0.26
 ??????? MVD Helper ? ???????? ?????????? Bank Helper

4. ???????? ? ??? ??????????? ????????????? ?????????
 - ????-????????
 - ????-??????
 - ????? Samp-Addon
 - ?????? LUA/CLEO/SF/ASI

5. ??? ?????? ??????? ????? ????????? ?????:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26
 - ?????????? (lib)

6. ???? ?????? ?????? ??????? ????? ? ????? ????????? ??? ??????, ?? ?????????? ??????? ?????????
- ? ????? moonloader > ??????? ????? CONFIG
- ? ????? moonloader > ??????? ????? BHelper

7. ???? ?????? ???????? ?? ???????, ?? ?????????? ?????????? ?????? ?? ?????? ??????

{00FFA5}??? ????? ??? ??????? ????? ????? ?? ??????, ??????? {33AA33}??????????? ? ????? ??????.

{FFFFFF}?????????? ???????????? ?????? ??????? ????? ??????????  ?????? CTRL + R]], "?????", _, 0)
			setClipboardText('https://yadi.sk/d/hLZTKsBhFcgzLA')
		end
	end
end

function sampGetPlayerSkin(id)
	if not id or not sampIsPlayerConnected(tonumber(id)) and not tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then 
		return false 
	end
	local isLocalPlayer = tonumber(id) == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
	local result, handle = sampGetCharHandleBySampPlayerId(tonumber(id))
	if not result and not isLocalPlayer then return false end
	local skinid = getCharModel(isLocalPlayer and PLAYER_PED or handle)
	if skinid < 0 or skinid > 311 then return false end
	return true, skinid
end

function autoGetSelfGender()
	local skins = {
		[1] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 149, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 304, 305, 310, 311}, 
		[2] = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307, 308, 309}
	}
	for k, v in pairs(skins) do
		for _, skin in pairs(v) do
			if skin == getCharModel(PLAYER_PED) then
				sex.v = k
				cfg.main.sex = sex.v
				return k
			end
		end
	end
	return nil
end

function isSkinBad(id)
	local bad_skins = { 63, 64, 75, 77, 78, 79, 87, 134, 135, 136, 152, 178, 200, 212, 230, 237, 239, 244, 246, 252, 256, 257 }
	for i, skin in ipairs(bad_skins) do
		if skin == id then
			return true
		end
	end
	return false
end

function isUniformWearing()
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED) 
	if sampGetPlayerColor(id) == 2150206647 then 
		return true
	end
	return false
end

function system_credit()
	if imgui.BeginPopupModal(u8("??????? ????????????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.InvisibleButton('##widewindowSC', imgui.ImVec2(400, 1))
		local credits = io.open("moonloader/BHelper/????????????.txt", "r+")
		for line in credits:lines() do
			imgui.CenterTextColoredRGB(line)
		end
		credits:close()
		imgui.Separator()
		imgui.CenterTextColoredRGB(mc..'?? ?????? ???????? ?? ????! {464646}> ?????? ??? <')
		imgui.Hint('openpathkredit', u8('??????? ??? ?? ??????? ????:\n' .. getWorkingDirectory() .. '\\BHelper\\????????????.txt'))
		if imgui.IsItemClicked() then
			os.execute('explorer '..getWorkingDirectory()..'\\BHelper\\????????????.txt')
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 80) / 2)
		if imgui.Button(u8("???????##????????????"), imgui.ImVec2(80, 20)) then
			imgui.CloseCurrentPopup()
		end

	imgui.EndPopup()
	end
end 

function system_cadr()
	if imgui.BeginPopupModal(u8("???????? ???????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then

		local cadrsys = io.open("moonloader/BHelper/???????? ???????.txt", "r+")
		for line in cadrsys:lines() do
			imgui.TextColoredRGB(line)
		end
		cadrsys:close()
		imgui.Separator()
		imgui.CenterTextColoredRGB(mc..'?? ?????? ???????? ?? ????! {464646}> ?????? ??? <')
		imgui.Hint('cardsystempath', u8('??????? ??? ?? ??????? ????:\n' .. getWorkingDirectory() .. '\\BHelper\\???????? ???????.txt'))
		if imgui.IsItemClicked() then
			os.execute('explorer '..getWorkingDirectory()..'\\BHelper\\???????? ???????.txt')
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 80) / 2)
		if imgui.Button(u8("???????##????????"), imgui.ImVec2(80, 20)) then
			imgui.CloseCurrentPopup()
		end

	imgui.EndPopup()
	end
end 

function system_uprank()
	if imgui.BeginPopupModal(u8("?????? ??????? ?????????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		
		local file = io.open("moonloader/BHelper/??????? ?????????.txt", "r+")
		for line in file:lines() do
			imgui.TextColoredRGB(line)
		end
		file:close()
		imgui.Separator()
		imgui.CenterTextColoredRGB(mc..'?? ?????? ???????? ?? ????! {464646}> ?????? ??? <')
		imgui.Hint('prosystematization', u8('??????? ??? ?? ??????? ????:\n' .. getWorkingDirectory() .. '\\BHelper\\??????? ?????????.txt'))
		if imgui.IsItemClicked() then
			os.execute('explorer '..getWorkingDirectory()..'\\BHelper\\??????? ?????????.txt')
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 80) / 2)
		if imgui.Button(u8("???????##Promotion"), imgui.ImVec2(80, 20)) then
			imgui.CloseCurrentPopup()
		end

	imgui.EndPopup()
	end
end

local posts = {
	["????? - 2"]   = {x = -2693.7869, y = 797.9387, z = 1500},
	["???? - 2"]    = {x = -2693.7881, y = 794.1193, z = 1500},
	["???? - 4"]    = {x = -2687.8120, y = 806.7342, z = 1500},
	["??? - 5"]     = {x = -2667.4160, y = 789.8926, z = 1500},
	["?????"]       = {x = -2694.0479, y = 809.4982, z = 1500},
}

function post()
	if imgui.BeginPopupModal(u8("???????????? ??????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		for post, coord in pairs(posts) do
			if imgui.Button(u8(post), imgui.ImVec2(250, 30)) then
				if getCharActiveInterior(PLAYER_PED) ~= 0 or devmode then
					setMarker(1, coord.x, coord.y, coord.z, 1, 0xFFFF0000)
					addBankMessage('????????????? ?? ????????????? ??????')
					imgui.CloseCurrentPopup()
					bank.v = false
				else
					addBankMessage('???????? ?????? ? ?????????!')
				end
			end
		end
		
		if imgui.MainButton(u8("????? ???????"), imgui.ImVec2(250, 30)) then
			sampSetChatInputEnabled(true)
			sampSetChatInputText("/r ???????????: {my_name} | ????:  | ?????????: ??????????")
			sampSetChatInputCursor(34, 34)
			addBankMessage('????? ??????????? ? ????? ??????, ? ??? ?? ???????? ? ???? ????')
			addBankMessage('??? {M}{my_name}{W} ????????????? ?????????? ?? ??? ??? ??? ????????')
			addBankMessage('??? ???????? ????????????? ?????? ?????? ?????? ? ??? !???? (?? ?????????)')
			setClipboardText(u8:decode("/r ??????????? {my_name} | ????: [??? ????] | ?????????: ??????????"))
			imgui.CloseCurrentPopup()
			bank.v = false
		end
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 80) / 2)
		if imgui.MainButton(u8("???????##Docs"), imgui.ImVec2(80, 20)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function gov()
	if imgui.BeginPopupModal(u8("???????????? ??????????????? ?????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then

		if hGov.v > 23 then hGov.v = 0 end
		if mGov.v > 59 then mGov.v = 0 end
		if hGov.v < 0 then hGov.v = 23 end
		if mGov.v < 0 then mGov.v = 55 end

		imgui.PushButtonRepeat(true)
		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 1))
		imgui.SetCursorPosX(30)
		if imgui.Button('+##PlusHour', imgui.ImVec2(40, 20)) then
			status_button_gov = false
			hGov.v = hGov.v + 1
		end
		imgui.SameLine(93)
		if imgui.Button('+##PlusMin', imgui.ImVec2(40, 20)) then
			status_button_gov = false 
			mGov.v = mGov.v + 5
		end

		imgui.PushFont(font[35])
		if #tostring(hGov.v) == 1 then zeroh = '0' else zeroh = '' end
		if #tostring(mGov.v) == 1 then zerom = '0' else zerom = '' end
		imgui.SetCursorPosX(30)
		imgui.TextColoredRGB(tostring(zeroh..hGov.v)..' : '..tostring(zerom..mGov.v))
		imgui.PopFont()

		imgui.SetCursorPosX(30)
		if imgui.Button('-##MinusHour', imgui.ImVec2(40, 20)) then
			status_button_gov = false
			hGov.v = hGov.v - 1
		end
		imgui.SameLine(93)
		if imgui.Button('-##MinusMin', imgui.ImVec2(40, 20)) then
			status_button_gov = false
			mGov.v = mGov.v - 5
		end
		imgui.PopStyleVar()
		imgui.PopButtonRepeat()

		imgui.CenterTextColoredRGB(mc..'????? ??????????????? ?????:')
		imgui.PushItemWidth(600)
		if gosDep.v then
			imgui.TextDisabled('/d'); imgui.SameLine(40)
			imgui.InputText('##govdep1', govdep[1])
		end
		imgui.TextDisabled('/gov'); imgui.SameLine(40); imgui.InputText('##govstr1', govstr[1])
		imgui.TextDisabled('/gov'); imgui.SameLine(40); imgui.InputText('##govstr2', govstr[2])
		imgui.TextDisabled('/gov'); imgui.SameLine(40); imgui.InputText('##govstr3', govstr[3])
		if gosDep.v then
			imgui.TextDisabled('/d'); imgui.SameLine(40)
			imgui.InputText('##govdep2', govdep[2])
		end
		imgui.PopItemWidth()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
		if imgui.Button(u8'?????????', imgui.ImVec2(160, 20)) then
			cfg.govstr[1] = u8:decode(govstr[1].v)
			cfg.govstr[2] = u8:decode(govstr[2].v)
			cfg.govstr[3] = u8:decode(govstr[3].v)
			--
			cfg.govdep[1] = u8:decode(govdep[1].v)
			cfg.govdep[2] = u8:decode(govdep[2].v)
			inicfg.save(cfg, 'Bank_Config.ini')
			imgui.CloseCurrentPopup()
		end

		imgui.SetCursorPos(imgui.ImVec2(150, 30))
		imgui.BeginChild("##SettingsGov", imgui.ImVec2(-1, 75), true)
		imgui.ToggleButton('##gosScreen', gosScreen); imgui.SameLine()
		imgui.TextColoredRGB('????-????? ????? ??????')
		imgui.ToggleButton('##gosDep', gosDep); imgui.SameLine()
		imgui.TextColoredRGB('???????? ????? ? /d')
		imgui.PushItemWidth(100)
		if imgui.InputInt('##delayGov', delayGov) then 
			if delayGov.v < 0 then delayGov.v = 0 end
			if delayGov.v > 10000 then delayGov.v = 10000 end
		end
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.TextColoredRGB('???????? {565656}(?)')
		imgui.Hint('infodelaygov', u8('???????? ????? ??????????? ? GOV-?????\n??????????? ? ????????????? (1000 ?? = 1 ???)'))
		imgui.SetCursorPos(imgui.ImVec2(300, 10))
		if not status_button_gov then 
			if tonumber(os.date("%H", os.time())) == hGov.v and tonumber(os.date("%M", os.time())) == mGov.v then
				imgui.DisableButton(u8'????????##gov', imgui.ImVec2(-1, -1))
			else
				if imgui.GreenButton(u8'????????##gov', imgui.ImVec2(-1, -1)) then 
					status_button_gov = true
					antiflud = true
				end
			end
		else
			if imgui.RedButton(u8'?? ??????: '..getOstTime(), imgui.ImVec2(-1, -1)) then 
				status_button_gov = false
			end
		end
		imgui.EndChild()
		imgui.EndPopup()
	end
end

function getOstTime()
	local datetime = {
		year  = os.date("%Y", os.time()),
		month = os.date("%m", os.time()),
		day   = os.date("%d", os.time()),
		hour  = hGov.v,
		min   = mGov.v,
		sec   = 00
	}
	if os.time(datetime) - os.time() < 0 then
		datetime.day = os.date("%d", os.time()) + 1
		return tostring(get_timer(os.time(datetime) - os.time()))
	else
		return tostring(get_timer(os.time(datetime) - os.time()))
	end
end

function BlackListGui()
	if imgui.BeginPopupModal(u8("׸???? ?????? ?????????????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.CenterText(u8('??????? ????????? ? ???? ???????\nc????? ?? ???? ??? ??????? ? ???????????'))
		if #cfg.blacklist > 0 then
			imgui.CenterText(u8('??? ?? ??????? - ???????? ???? ??????'), imgui.ImVec4(1.0, 0.5, 0.5, 0.7))
		end
		imgui.BeginChild("##BlakList", imgui.ImVec2(300, 250), true, imgui.WindowFlags.NoScrollbar)
		imgui.PushFont(font[15])
		if #cfg.blacklist == 0 then
			imgui.SetCursorPosY(110)
			imgui.CenterText(u8'?????? ????', imgui.ImVec4(1.0, 1.0, 1.0, 0.3))
		end
		for i, nick in ipairs(cfg.blacklist) do
			imgui.CenterText(u8(nick))
			if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
				addBankMessage(string.format('????? {M}%s{W} ?????? ?? ??????? ??????!', nick))
				table.remove(cfg.blacklist, i)
			end
		end
		imgui.PopFont()
		imgui.EndChild()
		imgui.PushItemWidth(200)
		imgui.InputText('##AddNewInList', blacklist)
		imgui.PopItemWidth()
		imgui.SameLine()
		if #blacklist.v > 0 then
			if imgui.Button(u8'????????', imgui.ImVec2(-1, 20)) then
				table.insert(cfg.blacklist, u8:decode(tostring(blacklist.v)))
				blacklist.v = ''
			end
		else
			imgui.DisableButton(u8'????????', imgui.ImVec2(-1, 20))
		end

		if imgui.Button(u8("????????? ? ?????##BlackList"), imgui.ImVec2(-1, 25)) then
			inicfg.save(cfg, 'Bank_Config.ini')
			addBankMessage('?????? ????????!')
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function binder()
	if imgui.BeginPopupModal(u8("??????????????/???????? ?????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.BeginChild("##EditBinder", imgui.ImVec2(500, 355), true)
			imgui.PushItemWidth(150)
			imgui.InputInt(u8("???????? ????? ???????? ? ?????????????"), binder_delay); imgui.SameLine(); imgui.TextDisabled('(?)')
			imgui.Hint('maxdelaybinder', u8('?? ?????? 60.000ms!\n(1 sec = 1000 ms)'))
			imgui.PopItemWidth()
			if binder_delay.v <= 0 then
				binder_delay.v = 1
			elseif binder_delay.v >= 60001 then
				binder_delay.v = 60000
			end

			imgui.TextWrapped(u8("?? ?????? ???????????? ????????? ???? ??? ????? ??????!"))
			imgui.SameLine(); imgui.TextDisabled(u8'(?????????)')
			if imgui.IsItemClicked() then
				imgui.OpenPopup(u8("????????? ????"))
			end
			taginfo()
			imgui.InputTextMultiline("##EditMultiline", text_binder, imgui.ImVec2(-1, 250))
			imgui.Text(u8'???????? ????? (???????????):'); imgui.SameLine()
			imgui.PushItemWidth(150)
			imgui.InputText("##binder_name", binder_name)
			imgui.PopItemWidth()
			if #binder_name.v > 0 and #text_binder.v > 0 then
				imgui.SameLine()
				if imgui.MainButton(u8("?????????"), imgui.ImVec2(-1, 20)) then
					if not EditOldBind then
						refresh_text = text_binder.v:gsub("\n", "~")
						table.insert(cfg.Binds_Name, binder_name.v)
						table.insert(cfg.Binds_Action, refresh_text)
						table.insert(cfg.Binds_Deleay, binder_delay.v)
						if inicfg.save(cfg, 'Bank_Config.ini') then
							addBankMessage(string.format('???? {M}?%s?{W} ??????? ????????!', u8:decode(binder_name.v)))
							binder_name.v, text_binder.v = '', ''
						end
						binder_open = false
						imgui.CloseCurrentPopup()
					else
						refresh_text = text_binder.v:gsub("\n", "~")
						table.insert(cfg.Binds_Name, getpos, binder_name.v)
						table.insert(cfg.Binds_Action, getpos, refresh_text)
						table.insert(cfg.Binds_Deleay, getpos, binder_delay.v)
						table.remove(cfg.Binds_Name, getpos + 1)
						table.remove(cfg.Binds_Action, getpos + 1)
						table.remove(cfg.Binds_Deleay, getpos + 1)
						if inicfg.save(cfg, 'Bank_Config.ini') then
							addBankMessage(string.format('???? {M}?%s?{W} ??????? ??????????????!', u8:decode(binder_name.v)))
							binder_name.v, text_binder.v = '', ''
						end
						EditOldBind = false
						binder_open = false
						imgui.CloseCurrentPopup()
					end
				end
			else
				imgui.SameLine()
				imgui.DisableButton(u8("?????????"), imgui.ImVec2(-1, 20))
				imgui.Hint('errgrafsbinder', u8'????????? ?? ??? ??????!')
			end
			if imgui.Button(u8("???????"), imgui.ImVec2(-1, 0)) then
				if not EditOldBind then
					if #text_binder.v == 0 then
						binder_open = false
						imgui.CloseCurrentPopup()
						binder_name.v, text_binder.v = '', ''
					else
						imgui.OpenPopup(u8("???????????##AcceptCloseBinderEdit"))
					end
				else
					EditOldBind = false
					binder_open = false
					imgui.CloseCurrentPopup()
					binder_name.v, text_binder.v = '', ''
				end
			end
			if imgui.BeginPopupModal(u8("???????????##AcceptCloseBinderEdit"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##AcceptCloseBinderEdit", imgui.ImVec2(300, 80), false)
				imgui.CenterTextColoredRGB('?? ??? ?????? ???-?? ?????? ? ?????\n????????? ??? ?????????')
				if imgui.MainButton(u8'?????????##accept', imgui.ImVec2(145, 20)) then
					imgui.CloseCurrentPopup()
					savedatamlt = true
				end
				imgui.SameLine()
				if imgui.MainButton(u8'?? ?????????##accept', imgui.ImVec2(145, 20)) then
					imgui.CloseCurrentPopup()
					nonsavedatamlt = true
				end
				if imgui.Button(u8'????????? ?????##accept', imgui.ImVec2(-1, 20)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndChild()
				imgui.EndPopup()
			end
			if savedatamlt then 
				savedatamlt = false
				binder_open = false
				imgui.CloseCurrentPopup()
			elseif nonsavedatamlt then 
				nonsavedatamlt = false
				binder_open = false
				imgui.CloseCurrentPopup()
				binder_name.v, text_binder.v = '', ''
			end
			imgui.EndChild()
		imgui.EndPopup()
	end
end

function set_style(c)
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowRounding = 3.0
	style.FrameRounding = 3.0
	style.ChildWindowRounding = 3.0
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)

	colors[clr.Text]                   = ImVec4(c['T'].x, c['T'].y, c['T'].z, 1.00);
	colors[clr.TextDisabled]           = ImVec4(c['T'].x, c['T'].y, c['T'].z, 0.50);
	colors[clr.WindowBg]               = ImVec4(c['B'].x, c['B'].y, c['B'].z, 0.95);
	colors[clr.ChildWindowBg]          = ImVec4(c['B'].x, c['B'].y, c['B'].z, 1.00);
	colors[clr.PopupBg]                = ImVec4(c['B'].x, c['B'].y, c['B'].z, 0.90);
	colors[clr.Border]                 = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.FrameBg]                = ImVec4(0.50, 0.50, 0.50, 0.30);
	colors[clr.FrameBgHovered]         = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.50);
	colors[clr.FrameBgActive]          = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.TitleBg]                = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.TitleBgActive]          = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.90);
	colors[clr.TitleBgCollapsed]       = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.ScrollbarBg]            = ImVec4(c['B'].x, c['B'].y, c['B'].z, 0.95);
	colors[clr.ScrollbarGrab]          = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.ScrollbarGrabHovered]   = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.90);
	colors[clr.ScrollbarGrabActive]    = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.ComboBg]                = ImVec4(c['B'].x, c['B'].y, c['B'].z, 0.90);
	colors[clr.CheckMark]              = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.SliderGrab]             = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.SliderGrabActive]       = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.Button]                 = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.90);
	colors[clr.ButtonHovered]          = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.ButtonActive]           = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.60);
	colors[clr.Header]                 = ImVec4(c['E'].x, c['E'].y, c['E'].z, 1.00);
	colors[clr.HeaderHovered]          = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.90);
	colors[clr.HeaderActive]           = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.80);
	colors[clr.TextSelectedBg]         = ImVec4(c['E'].x, c['E'].y, c['E'].z, 0.60);
	colors[clr.CloseButton]            = ImVec4(c['T'].x, c['T'].y, c['T'].z, 0.20);
	colors[clr.CloseButtonHovered]     = ImVec4(c['T'].x, c['T'].y, c['T'].z, 0.30);
	colors[clr.CloseButtonActive]      = ImVec4(c['T'].x, c['T'].y, c['T'].z, 0.40);
	colors[clr.ModalWindowDarkening]   = ImVec4(c['B'].x, c['B'].y, c['B'].z, 0.05)
end

set_style(SCRIPT_STYLE.colors)

function taginfo()
	if imgui.BeginPopupModal(u8("????????? ????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.CenterTextColoredRGB(sc..'????? ?? ?????? ???, ??? ?? ??????????? ???')
		imgui.Separator()
		if imgui.Button('{select_id}', imgui.ImVec2(120, 25)) then setClipboardText('{select_id}'); addBankMessage('??? ??????????!') end
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? ID ?????? ? ??????? ????????????????')
		if imgui.Button('{select_name}', imgui.ImVec2(120, 25)) then setClipboardText('{select_name}'); addBankMessage('??? ??????????!') end
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? NickName ?????? ? ??????? ????????????????')
		if imgui.Button('{my_id}', imgui.ImVec2(120, 25)) then setClipboardText('{my_id}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagmyid', u8'{my_id}\n - '..select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? ??? ID')
		if imgui.Button('{my_name}', imgui.ImVec2(120, 25)) then setClipboardText('{my_name}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagmyname', u8'{my_name}\n - '..rpNick(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? ??? NickName')
		if imgui.Button('{closest_id}', imgui.ImVec2(120, 25)) then setClipboardText('{closest_id}'); addBankMessage('??? ??????????!') end
		imgui.Hint('taglosestid', u8'????? ?? ???? ????? ??????? ? ????????? "{closest_id}"\n - ????? ?? ???? ????? ??????? ? ????????? "228"')
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? ID ?????????? ? ??? ??????')
		if imgui.Button('{closest_name}', imgui.ImVec2(120, 25)) then setClipboardText('{closest_name}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagclosestname', u8'????? ?? ???? ????? {closest_name}\n - ????? ?? ???? ????? Jeffy_Cosmo')
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? NickName ?????????? ? ??? ??????')
		if imgui.Button('{time}', imgui.ImVec2(120, 25)) then setClipboardText('{time}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagtime', u8'/do ?? ????? {time_s}\n - /do ?? ????? '..os.date("%H:%M", os.time()))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'??????? ????? ( ??:?? )')
		if imgui.Button('{time_s}', imgui.ImVec2(120, 25)) then setClipboardText('{time_s}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagtimes', u8'/do ?? ????? {time_s}\n - /do ?? ????? '..os.date("%H:%M:%S", os.time()))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'??????? ????? ( ??:??:?? )')
		if imgui.Button('{rank}', imgui.ImVec2(120, 25)) then setClipboardText('{rank}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagrank', u8('??? ????????? - {rank}\n - ??? ????????? - '..cfg.nameRank[cfg.main.rank]))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? ?????? ???????? ?????')
		if imgui.Button('{score}', imgui.ImVec2(120, 25)) then setClipboardText('{rank}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagscore', u8('? ???????? ? ????? ??? {score} ???\n - ? ???????? ? ????? ??? '..sampGetPlayerScore(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))..' ???'))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'??? ??????? ???????')
		if imgui.Button('{screen}', imgui.ImVec2(120, 25)) then setClipboardText('{screen}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagscreen', u8('/giverank 123 5 {screen}\n - ???????? ???????: /giverank 123 5, ? ????? ??????? ????????'))
		imgui.SameLine(); imgui.TextColoredRGB(mc..'?????? ????????')
		if imgui.Button('{sex:text1|text2}', imgui.ImVec2(120, 25)) then setClipboardText('{sex:text1|text2}'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagsex', u8'/me {sex:????|?????} ????? ?? ?????\n - ???? ??????? ???: /me ????..\n - ???? ??????? ???: /me ?????')
		imgui.SameLine(); imgui.TextColoredRGB(mc..'?????? ????? ? ??????????? ?? ?????? ????')
		if imgui.Button(u8'@[ID ??????]', imgui.ImVec2(120, 25)) then setClipboardText('@[ID]'); addBankMessage('??? ??????????!') end
		imgui.Hint('tagmention', u8'/fam @228 ???????? ???????\n - /fam Jeffy Cosmo, ???????? ???????')
		imgui.SameLine(); imgui.TextColoredRGB(mc..'???????? NickName ?????? ?????????? ID ?? ???????')
		imgui.Separator()
		if imgui.Button(u8'????????? ?????##tag', imgui.ImVec2(-1, 30)) then
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function sampGetPlayerIdOnTargetKey(key)
	local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
	if result then
		if isKeyJustPressed(key) then
			return sampGetPlayerIdByCharHandle(ped)
		end
	end
	return false
end

function play_bind(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in cfg.Binds_Action[num]:gmatch('[^~]+') do
				sampSendChat(u8:decode(tostring(bp)))
				wait(cfg.Binds_Deleay[num])
			end
			num = -1
		end
	end)
end

function frpbat()
	local weapon = getCurrentCharWeapon(PLAYER_PED)
	if weapon == 3 and not rp_check then 
		sampSendChat(cfg.main.rpbat_true)
		rp_check = true
	elseif weapon ~= 3 and rp_check then
		sampSendChat(cfg.main.rpbat_false)
		rp_check = false
	end
end

function getPlayerIdByNickname(name)
	for i = 0, sampGetMaxPlayerId(false) do
		if sampIsPlayerConnected(i) or i == select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) then
			if sampGetPlayerNickname(i):lower() == tostring(name):lower() then return i end
		end
	end
end

function imgui.CenterTextColoredRGB(text)
	local width = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end

	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local textsize = w:gsub('{.-}', '')
			local text_width = imgui.CalcTextSize(u8(textsize))
			imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else
				imgui.Text(u8(w))
			end
		end
	end
	render_text(text)
end

function se.onSendChat(msg)
	if msg:find('{select_id}') then
		if actionId ~= nil then
			msg = msg:gsub('{select_id}', actionId)
			return { msg }
		end
		addBankMessage('?? ??? ?? ???????? ?????? ??? ???? {M}{select_id}')
		return false
	end

	if msg:find('{select_name}') then
		if actionId ~= nil then
			msg = msg:gsub('{select_name}', rpNick(actionId))
			return { msg }
		end
		addBankMessage('?? ??? ?? ???????? ?????? ??? ???? {M}{select_name}')
		return false
	end

	if msg:find('{my_id}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		msg = msg:gsub('{my_id}', tostring(id))
		return { msg }
	end

	if msg:find('{my_name}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		msg = msg:gsub('{my_name}', rpNick(id))
		return { msg }
	end

	if msg:find('{closest_id}') then
		local result, id = getClosestPlayerId()
		if result then
			msg = msg:gsub('{closest_id}', tostring(id))
			return { msg }
		end
		addBankMessage('? ????? ??????? ??? ??????? ??? ?????????? ???? {M}{closest_id}')
		return false
	end

	if msg:find('{closest_name}') then
		local result, id = getClosestPlayerId()
		if result then
			msg = msg:gsub('{closest_name}', rpNick(id))
			return { msg }
		end
		addBankMessage('? ????? ??????? ??? ??????? ??? ?????????? ???? {M}{closest_name}')
		return false
	end

	if msg:find('@%d+') then
		local id = msg:match('@(%d+)')
		if id and sampIsPlayerConnected(id) then
			local nickname = rpNick(id)
			msg = msg:gsub('@%d+', nickname)
			return { msg }
		end
		addBankMessage('?????? ? ????? ID ?? ??????? ???!')
		return false
	end

	if msg:find('{time}') then
		msg = msg:gsub('{time}', os.date("%H:%M", os.time()))
		return { msg }
	end

	if msg:find('{time_s}') then
		msg = msg:gsub('{time_s}', os.date("%H:%M:%S", os.time()))
		return { msg }
	end

	if msg:find('{rank}') then
		msg = msg:gsub('{rank}', cfg.nameRank[cfg.main.rank])
		return { msg }
	end

	if msg:find('{score}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		msg = msg:gsub('{score}', sampGetPlayerScore(id))
		return { msg }
	end

	if msg:find('{sex:%A+|%A+}') then
        local male, female = msg:match('{sex:(%A+)|(%A+)}')
        if cfg.main.sex == 1 then
        	local returnMsg = msg:gsub('{sex:%A+|%A+}', male, 1)
        	sampSendChat(tostring(returnMsg))
        	return false
        else
        	local returnMsg = msg:gsub('{sex:%A+|%A+}', female, 1)
        	sampSendChat(tostring(returnMsg))
        	return false
        end
    end

	if msg:find('{screen}') then
		lua_thread.create(function()
			wait(0) sampSendChat('/time')
			wait(500) takeScreenshot()
		end)
		msg = msg:gsub('{screen}', '')
		return #msg > 0 and { msg } or false
	end

	if cfg.main.accent_status then
		if #msg > 0 then
			if msg ~= ')' and msg ~= '(' and msg ~= '))' and msg ~= '((' and msg ~= 'xD' and msg ~= ':D' then
				msg = string.format('%s %s', cfg.main.accent, msg)
				return { msg }
			end
		end
	end
end

function se.onSendCommand(cmd)
	if cmd:find('{select_id}') then
		if actionId ~= nil then
			cmd = cmd:gsub('{select_id}', actionId)
			return { cmd }
		end
		addBankMessage('?? ??? ?? ???????? ?????? ??? ???? {M}{select_id}')
		return false
	end

	if cmd:find('{select_name}') then
		if actionId ~= nil then
			cmd = cmd:gsub('{select_name}', rpNick(actionId))
			return { cmd }
		end
		addBankMessage('?? ??? ?? ???????? ?????? ??? ???? {M}{select_name}')
		return false
	end

	if cmd:find('{my_id}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		cmd = cmd:gsub('{my_id}', tostring(id))
		return { cmd }
	end

	if cmd:find('{my_name}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		cmd = cmd:gsub('{my_name}', rpNick(id))
		return { cmd }
	end

	if cmd:find('{closest_id}') then
		local result, id = getClosestPlayerId()
		if result then
			cmd = cmd:gsub('{closest_id}', tostring(id))
			return { cmd }
		end
		addBankMessage('? ????? ??????? ??? ??????? ??? ?????????? ???? {M}{closest_id}')
		return false
	end

	if cmd:find('{closest_name}') then
		local result, id = getClosestPlayerId()
		if result then
			cmd = cmd:gsub('{closest_name}', rpNick(id))
			return { cmd }
		end
		addBankMessage('? ????? ??????? ??? ??????? ??? ?????????? ???? {M}{closest_name}')
		return false
	end

	if cmd:find('@%d+') then
		local id = cmd:match('@(%d+)')
		if id and sampIsPlayerConnected(id) then
			local nickname = rpNick(id)
			cmd = cmd:gsub('@%d+', nickname)
			return { cmd }
		end
		addBankMessage('?????? ? ????? ID ?? ??????? ???!')
		return false
	end

	if cmd:find('{time}') then
		cmd = cmd:gsub('{time}', os.date("%H:%M", os.time()))
		return { cmd }
	end

	if cmd:find('{time_s}') then
		cmd = cmd:gsub('{time_s}', os.date("%H:%M:%S", os.time()))
		return { cmd }
	end

	if cmd:find('{rank}') then
		cmd = cmd:gsub('{rank}', cfg.nameRank[cfg.main.rank])
		return { cmd }
	end

	if cmd:find('{score}') then
		local id = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
		cmd = cmd:gsub('{score}', sampGetPlayerScore(id))
		return { cmd }
	end

	if cmd:find('{sex:%A+|%A+}') then
        local male, female = cmd:match('{sex:(%A+)|(%A+)}')
        if cfg.main.sex == 1 then
        	local returnMsg = cmd:gsub('{sex:%A+|%A+}', male, 1)
        	sampSendChat(tostring(returnMsg))
        	return false
        else
        	local returnMsg = cmd:gsub('{sex:%A+|%A+}', female, 1)
        	sampSendChat(tostring(returnMsg))
        	return false
        end
    end

	if cmd:find('{screen}') then
		lua_thread.create(function()
			wait(0) sampSendChat('/time')
			wait(500) takeScreenshot()
		end)
		cmd = cmd:gsub('{screen}', '')
		return #cmd > 0 and { cmd } or false
	end

	if cfg.main.accent_status then
		local text = cmd:match('^/[cs] (.+)')
		if text then
			cmd = cmd:gsub(text, string.format('%s %s', cfg.main.accent, text))
			return { cmd }
		end
	end

	if cmd:match('^/jobprogress %d+$') then
		local id = cmd:match('/jobprogress (%d+)$')
		local result, dist = getDistBetweenPlayers(id)
		if result and dist < 5 then
			sampAddChatMessage('[??????????] {FFFFFF}?? ???????? ???? {4EB857}???????? ????????????{FFFFFF} ?????? '..rpNick(id)..'!', 0x4EB857)
		end
	end

	if cmd:match('^/premium %d+ %d+ %d+') and cfg.main.rank >= 9 then
		local rank = cmd:match('^/premium %d+ %d+ (%d+)')
		if rank then
			rank = tonumber(rank)
			if cfg.nameRank[rank] ~= nil and temp_prem ~= cfg.nameRank[rank] then
				temp_prem = cfg.nameRank[rank]
				sampSendChat('?????? ??? ??????????? ?? ????????? ' .. temp_prem)
				sampSendChat(cmd)
				return false
			end
		end
	end
end

function getClosestPlayerId()
	local temp = {}
	local tPeds = getAllChars()
	local me = {getCharCoordinates(PLAYER_PED)}
	for i, ped in ipairs(tPeds) do 
		local result, id = sampGetPlayerIdByCharHandle(ped)
		if ped ~= PLAYER_PED and result then
			local pl = {getCharCoordinates(ped)}
			local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
			temp[#temp + 1] = { dist, id }
		end
	end
	if #temp > 0 then
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		return true, temp[1][2]
	end
	return false
end

function get_timer(time)
	return string.format("%s:%s:%s", string.format("%s%s", (tonumber(os.date("%H", time)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", time)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", time)) - tonumber(os.date("%H", 0))) < 10 and 0 or "", tonumber(os.date("%H", time)) < tonumber(os.date("%H", 0)) and 24 + tonumber(os.date("%H", time)) - tonumber(os.date("%H", 0)) or tonumber(os.date("%H", time)) - tonumber(os.date("%H", 0))), os.date("%M", time), os.date("%S", time))
end

function getDistBetweenPlayers(playerId)
	if playerId == nil then return false end
	local result, ped = sampGetCharHandleBySampPlayerId(playerId)
	if result then
		local me = {getCharCoordinates(PLAYER_PED)}
		local pl = {getCharCoordinates(ped)}
		local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
		return true, dist
	end
	return false
end

function setMarker(type, x, y, z, radius, color)
	deleteCheckpoint(marker)
	removeBlip(checkpoint)
	checkpoint = addBlipForCoord(x, y, z)
	marker = createCheckpoint(type, x, y, z, 1, 1, 1, radius)
	changeBlipColour(checkpoint, color)
	lua_thread.create(function()
	repeat
		wait(0)
		local x1, y1, z1 = getCharCoordinates(PLAYER_PED)
		until getDistanceBetweenCoords3d(x, y, z, x1, y1, z1) < radius or not doesBlipExist(checkpoint)
		deleteCheckpoint(marker)
		removeBlip(checkpoint)
		addOneOffSound(0, 0, 0, 1149)
	end)
end

function imgui.TextColoredRGB(text)
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end

	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end
			if text[0] then
				for i = 0, #text do

					imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end

	render_text(text)
end

Button_ORIGINAL = imgui.Button
function imgui.Button(label, size)
    local duration = {
        1.0, -- ???????????? ????????? ????? hovered / idle
        0.3  -- ???????????? ???????? ????? ???????
    }

    local cols = {
        default = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.Button]),
        hovered = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]),
        active  = imgui.ImVec4(imgui.GetStyle().Colors[imgui.Col.ButtonActive])
    }

    if not FBUTPOOL then FBUTPOOL = {} end
    if not FBUTPOOL[label] then
        FBUTPOOL[label] = {
            color = cols.default,
            clicked = { nil, nil },
            hovered = {
                cur = false,
                old = false,
                clock = nil,
            }
        }
    end

    if FBUTPOOL[label]['clicked'][1] and FBUTPOOL[label]['clicked'][2] then
        if os.clock() - FBUTPOOL[label]['clicked'][1] <= duration[2] then
            FBUTPOOL[label]['color'] = degrade(
                FBUTPOOL[label]['color'],
                cols.active,
                FBUTPOOL[label]['clicked'][1],
                duration[2]
            )
            goto no_hovered
        end

        if os.clock() - FBUTPOOL[label]['clicked'][2] <= duration[2] then
            FBUTPOOL[label]['color'] = degrade(
                FBUTPOOL[label]['color'],
                FBUTPOOL[label]['hovered']['cur'] and cols.hovered or cols.default,
                FBUTPOOL[label]['clicked'][2],
                duration[2]
            )
            goto no_hovered
        end
    end

    if FBUTPOOL[label]['hovered']['clock'] ~= nil then
        if os.clock() - FBUTPOOL[label]['hovered']['clock'] <= duration[1] then
            FBUTPOOL[label]['color'] = degrade(
                FBUTPOOL[label]['color'],
                FBUTPOOL[label]['hovered']['cur'] and cols.hovered or cols.default,
                FBUTPOOL[label]['hovered']['clock'],
                duration[1]
            )
        else
            FBUTPOOL[label]['color'] = FBUTPOOL[label]['hovered']['cur'] and cols.hovered or cols.default
        end
    end

    ::no_hovered::

    imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(FBUTPOOL[label]['color']))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(FBUTPOOL[label]['color']))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(FBUTPOOL[label]['color']))
    local result = Button_ORIGINAL(label, size or imgui.ImVec2(0, 0))
    imgui.PopStyleColor(4)

    if result then
        FBUTPOOL[label]['clicked'] = {
            os.clock(),
            os.clock() + duration[2]
        }
    end

    FBUTPOOL[label]['hovered']['cur'] = imgui.IsItemHovered()
    if FBUTPOOL[label]['hovered']['old'] ~= FBUTPOOL[label]['hovered']['cur'] then
        FBUTPOOL[label]['hovered']['old'] = FBUTPOOL[label]['hovered']['cur']
        FBUTPOOL[label]['hovered']['clock'] = os.clock()
    end

    return result
end

function imgui.MainButton(...)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.30, 0.80, 1.00))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.30, 0.80, 0.90))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.80, 0.80))
	local button = imgui.Button(...)
	imgui.PopStyleColor(3)
	return button
end

function imgui.RedButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.50, 0.00, 0.00, 1.00))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(3)
	return button
end

function imgui.GreenButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(3)
	return button
end

function imgui.DisableButton(text, size)
	imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.0, 0.0, 0.0, 0.2))
	imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.0, 0.0, 0.0, 0.2))
	imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.0, 0.0, 0.0, 0.2))
		local button = imgui.Button(text, size)
	imgui.PopStyleColor(3)
	return button
end

local orig_collheader = imgui.CollapsingHeader
function imgui.CollapsingHeader( ... )
	imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1.0, 1.0, 1.0, 1.0))
	local result = orig_collheader(...)
	imgui.PopStyleColor()
	return result
end

function imgui.CloseButton(rad)
	local pos = imgui.GetCursorScreenPos()
	local poss = imgui.GetCursorPos()
	local a, b, c, d = pos.x - rad, pos.x + rad, pos.y - rad, pos.y + rad
	local e, f = poss.x - rad, poss.y - rad
	local DL = imgui.GetWindowDrawList()
	imgui.SetCursorPos(imgui.ImVec2(e, f))
	local result = imgui.InvisibleButton('##CLOSE_BUTTON', imgui.ImVec2(rad * 2, rad * 2))
	DL:AddLine(imgui.ImVec2(a, d), imgui.ImVec2(b, c), 0xFF666666, 3)
	DL:AddLine(imgui.ImVec2(b, d), imgui.ImVec2(a, c), 0xFF666666, 3)
	return result
end

function stringToLower(s)
  for i = 192, 223 do
    s = s:gsub(_G.string.char(i), _G.string.char(i + 32))
  end
  s = s:gsub(_G.string.char(168), _G.string.char(184))
  return s:lower()
end

function stringToUpper(s)
  for i = 224, 255 do
    s = s:gsub(_G.string.char(i), _G.string.char(i - 32))
  end
  s = s:gsub(_G.string.char(184), _G.string.char(168))
  return s:upper()
end

function imgui.CenterText(text, color)
	color = color or imgui.GetStyle().Colors[imgui.Col.Text]
	local width = imgui.GetWindowWidth()
	for line in text:gmatch('[^\n]+') do
		local lenght = imgui.CalcTextSize(line).x
		imgui.SetCursorPosX((width - lenght) / 2)
		imgui.TextColored(color, line)
	end
end

function join_rgb(r, g, b)
	return bit.bor(bit.bor(b, bit.lshift(g, 8)), bit.lshift(r, 16))
end

function explode_argb(argb)
	local a = bit.band(bit.rshift(argb, 24), 0xFF)
	local r = bit.band(bit.rshift(argb, 16), 0xFF)
	local g = bit.band(bit.rshift(argb, 8), 0xFF)
	local b = bit.band(argb, 0xFF)
	return a, r, g, b
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function sampSetChatInputCursor(start, finish)
	local finish = finish or start
	local start, finish = tonumber(start), tonumber(finish)
	local chatInfoPtr = sampGetInputInfoPtr()
	local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
	memory.setint8(chatBoxInfo + 0x11E, start)
	memory.setint8(chatBoxInfo + 0x119, finish)
	return true
end

function checkServer(ip)
	local servers = {
		'185.169.134.3',
		'185.169.134.4',
		'185.169.134.43',
		'185.169.134.44', 
		'185.169.134.45',
		'185.169.134.5',
		'185.169.134.59',
		'185.169.134.61',
		'185.169.134.107',
		'185.169.134.109',
		'185.169.134.166',
		'185.169.134.171',
		'185.169.134.172',
		'185.169.134.173',
		'185.169.134.174',
		'80.66.82.191',
		'80.66.82.190',
		'80.66.82.188'
	}
	for i, v in pairs(servers) do
		if v == ip then
			log("???????? ?? ??????: {33AA33}??????? [ ?" .. i .. " ]", "??????????")
			return true
		end
	end
	log("???????? ?? ??????: {FF1010}???????? [ " .. ip .. " ]", "??????????")
	return false
end

function sumFormat(sum)
    if #sum > 3 then
        local b, e = ('%d'):format(sum):gsub('^%-', '')
        local c = b:reverse():gsub('%d%d%d', '%1.')
        local d = c:reverse():gsub('^%.', '')
        return (e == 1 and '-' or '')..d
    end
    return sum
end

function getNumberOfKassa()
	local p = {
		[1] = {x = -2665.1, y = 792.4, z = 1500.9},
		[2] = {x = -2665.1, y = 799.3, z = 1500.9},
		[3] = {x = -2665.1, y = 805.8, z = 1500.9},
		[4] = {x = -2668.9, y = 808.9, z = 1500.9},
		[5] = {x = -2676.3, y = 808.9, z = 1500.9},
		[6] = {x = -2683.8, y = 808.9, z = 1500.9}
	}
	for i = 1, 6 do
		local x, y, z = getCharCoordinates(PLAYER_PED)
		local dist = getDistanceBetweenCoords3d(x, y, z, p[i].x, p[i].y, p[i].z)
		if dist <= 3 then
			return true, i
		end
	end
	return false
end

function imgui.Repository(nameScript, nameLua, discription, cmds, d_Link, bh_Link)
	if imgui.Button(u8(nameScript), imgui.ImVec2(280, 30)) then 
		if not doesFileExist(getWorkingDirectory()..'\\'..nameLua) then
			downloadUrlToFile(d_Link, getWorkingDirectory()..'\\'..nameLua, function (id, status, p1, p2)
				if status == dlstatus.STATUSEX_ENDDOWNLOAD then
					addBankMessage(string.format("?????? %s ????????! ?????????..", nameScript))
					addBankMessage(string.format("??????? ?????????: {M}%s", cmds))
					script.load(getWorkingDirectory()..'\\'..nameLua)
				end
			end)
		else
			addBankMessage('? ??? ??? ?????????? ???? ??????!')
			imgui.OpenPopup(u8"??????? ???????##repository"..nameScript)
		end
	end
	imgui.Hint('repositoryact'..nameScript, u8(discription..'\n\n??????? ?????????: '..cmds))
	imgui.SameLine()
	if bh_Link then
		if imgui.Button(fa.ICON_FA_LINK..'##'..nameScript, imgui.ImVec2(-1, 30)) then os.execute('explorer '..bh_Link) end
		imgui.Hint('repositorylink'..nameScript, u8'?????? ???? ??????? ?? blast.hk')
	else
		imgui.DisableButton(fa.ICON_FA_BAN, imgui.ImVec2(-1, 30))
		imgui.Hint('repositorynolink'..nameScript, u8'????? ??????? ??? ??? ?? blast.hk')
	end

	if imgui.BeginPopupModal(u8"??????? ???????##repository"..nameScript, _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.CenterTextColoredRGB(sc .. nameScript .. '\n? ??? ??? ?????????? ??????\n?? ?????? ??????? ????')

		if imgui.RedButton(u8'???????##repository', imgui.ImVec2(150, 30)) then
			local script = script.find(nameLua)
			if script then script:unload() end
			os.remove(getWorkingDirectory()..'\\'..nameLua)
			addBankMessage('?????? ??????!')
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if imgui.Button(u8'????????##repository', imgui.ImVec2(150, 30)) then 
			imgui.CloseCurrentPopup()
		end
		imgui.EndPopup()
	end
end

function autoupdate(json_url)
	local dlstatus = require('moonloader').download_status
	local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
	if doesFileExist(json) then os.remove(json) end
	log('?????? ???????? ??????????', "??????????")
	downloadUrlToFile(json_url, json,
		function(id, status, p1, p2)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(json) then
				local f = io.open(json, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					updatelink = info.updateurl
					updateversion = info.latest
					f:close()
					os.remove(json)
					if updateversion ~= thisScript().version then
						lua_thread.create(function()
							local dlstatus = require('moonloader').download_status
							local color = -1
							log('??????? ??????????: '..thisScript().version..' -> '..updateversion..'! ????????..', "??????????")
							wait(250)
							downloadUrlToFile(updatelink, thisScript().path,
								function(id3, status1, p13, p23)
									if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
									elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
										log('???????? ????????. ?????? ???????? ?? ?????? '..mc..updateversion, "??????????")
										goupdatestatus = true

										local v1 = updateversion:match('^(%d+)')
										local v2 = thisScript().version:match('^(%d+)')
										if v1 ~= v2 then
											cfg.main.infoupdate = true
										end

										reload(false)
									end
									if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
										if goupdatestatus == nil then
											log('?????? ?? ???? ????????? ?? ?????? '..updateversion, "??????")
											update = false
										end
									end
								end
							)   
						end)
					else
						update = false
						log('?????? ?????????. ?????????? ???', "??????????")
						addBankMessage('?????????? ?? ???????')
					end
				end
			else
				log('?? ??????? ???????? JSON ???????', "??????")
				addBankMessage('?????????? ?? ???????')
				update = false
			end
		end
	end)
	while update ~= false do wait(100) end
end

function takeAutoScreen()
	if autoF8.v then
		hook_time = true
		sampSendChat('/time')
	end
end

function isPlayerOnBlacklist(player)
	for _, nick in ipairs(cfg.blacklist) do
		if nick == player then
			return true
		end
	end
	return false
end

function se.onDisplayGameText(style, time, text)
	if hook_time and text:find('Played') then
		lua_thread.create(function()
			wait(500)
			takeScreenshot()
		end)
		hook_time = false
	end
end

function unload(show_error)
	lua_thread.create(function()
		noErrorDialog = not show_error
		wait(100)
		thisScript():unload()
	end)
end

function reload(show_error)
	lua_thread.create(function()
		noErrorDialog = not show_error
		wait(100)
		thisScript():reload()
	end)
end

function takeScreenshot()
	memory.setuint8(sampGetBase() + 0x119CBC, 1)
end

function addBankMessage(message)
	message = message:gsub('{M}', mc)
	message = message:gsub('{W}', wc)
	message = message:gsub('{S}', sc)
	sampAddChatMessage(tag .. message, color or mcx)
end

function imgui.CenterText(text, color)
	color = color or imgui.GetStyle().Colors[imgui.Col.Text]
	local width = imgui.GetWindowWidth()
	for line in text:gmatch('[^\n]+') do
		local lenght = imgui.CalcTextSize(line).x
		imgui.SetCursorPosX((width - lenght) / 2)
		imgui.TextColored(color, line)
	end
end

function Window_Info_Update()
	if infoupdate.v then 
		local xx, yy = getScreenResolution()
		imgui.SetNextWindowSize(imgui.ImVec2(xx / 1.5, yy / 1.5), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(xx / 2, yy / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'##CHANGELOG', infoupdate, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollbar)
		
		imgui.SetCursorPos(imgui.ImVec2(10, 10))
		imgui.BeginGroup()
		imgui.PushFont(font[35])
		imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.ButtonHovered], fa.ICON_FA_NEWSPAPER .. u8' ?????? ?????????')
		imgui.PopFont()
		imgui.SetCursorPos(imgui.ImVec2( imgui.GetWindowWidth() - 30, 26 ))
		if imgui.CloseButton(7) then
			infoupdate.v = false
		end
		imgui.EndGroup()
		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(0, 0))
		imgui.Separator()
		imgui.PopStyleVar()

		local p = imgui.GetCursorScreenPos()
		local DL = imgui.GetWindowDrawList()
		local offset = 40

		local col_bg_line = black_theme.v and 0xFF404040 or 0xFFCC9000
		DL:AddLine(imgui.ImVec2(p.x + offset, p.y), imgui.ImVec2(p.x + offset, p.y + imgui.GetScrollMaxY() + imgui.GetWindowHeight()), col_bg_line, 10);

		imgui.SetCursorPosY(80)
		imgui.PushFont(font[15])
		imgui.BeginGroup()
			for i = #changelog, 1, -1 do
				local pos = imgui.GetCursorPos()
				local cl = changelog[i]
				local isLast = i == #changelog
				imgui.SetCursorPosX(offset + 30)
				imgui.BeginGroup()
					imgui.PushFont(font[20])
					local p2 = imgui.GetCursorScreenPos()
					local circle_color = black_theme.v and 0xFF707070 or 0xFFEEEEEE
					if cl.date == nil and isLast then -- is Beta
						circle_color = 0xFF0090FF
					elseif isLast then
						circle_color = 0xFFFF5000
					end
					local radius = isLast and 12 or 10
					DL:AddCircleFilled(imgui.ImVec2(p.x + offset + 1, p2.y + 10), radius, col_bg_line, 32)
					DL:AddCircleFilled(imgui.ImVec2(p.x + offset + 1, p2.y + 10), radius - 3, circle_color, 32)
					if cl.date ~= nil then
						imgui.TextColoredRGB('{0070FF}?????? ' .. cl.version)
						imgui.SameLine()
						imgui.TextColoredRGB('|  {5F99C2}' .. getTimeAfter(cl.date))
						imgui.PushFont(font[11])
						imgui.Hint('dateupdate'..i, u8(os.date('?? %d.%m.%Y', cl.date)))
						imgui.PopFont()
					else
						imgui.TextColoredRGB('{FF9000}?????? ' .. cl.version .. '-Beta')
					end
					imgui.PopFont()
					if cl.comment ~= "" then
						imgui.TextColored(imgui.ImVec4(0.4, 0.5, 0.7, 1.0), fa.ICON_FA_COMMENT .. ' ' .. u8(cl.comment))
					end
					for n, line in ipairs(cl.log) do
						if type(line) == 'table' then
							imgui.TextColoredRGB(' - ' .. line.title)
							local pp = imgui.GetCursorPos()
							local ss = imgui.CalcTextSize(u8(' - ' .. line.title))
							imgui.SetCursorPos( imgui.ImVec2(pp.x + ss.x + 10, pp.y - ss.y - 2) )
							imgui.PushFont(font[11])
							imgui.TextColored(imgui.ImVec4(0.4, 0.5, 0.7, 1.0), line.show and fa.ICON_FA_MINUS_CIRCLE or fa.ICON_FA_PLUS_CIRCLE)
							if imgui.IsItemClicked() then
								changelog[i].log[n].show = not changelog[i].log[n].show  
							end
							imgui.PopFont()
							if line.show then
								imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
								for _, dop in ipairs(line.more) do
									imgui.SetCursorPosX(offset + 55)
									imgui.TextWrapped(u8(dop))
								end
								imgui.PopStyleColor()
							end
						else
							imgui.TextWrapped(u8(' - ' .. line))
						end
					end
					if #cl.patches.info > 0 then
						imgui.TextColored(imgui.ImVec4(0.5, 0.6, 0.8, 1.0), u8(' >> ????? ').. (cl.patches.show and fa.ICON_FA_MINUS_CIRCLE or fa.ICON_FA_PLUS_CIRCLE))
						if imgui.IsItemClicked() then 
							changelog[i].patches.show = not changelog[i].patches.show
						end
						if cl.patches.show then
							imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(0.4, 0.5, 0.7, 1.0))
							for p, line in ipairs(cl.patches.info) do
								imgui.SetCursorPosX(offset + 45)
								imgui.TextWrapped(u8(p .. ') ' .. line))
							end
							imgui.PopStyleColor()
						end
					end
				imgui.EndGroup()
				imgui.Spacing()
			end
		imgui.EndGroup()
		imgui.PopFont()

		imgui.End()
	end
end

function degrade(before, after, start_time, duration)
	local result_vec4 = before
	local timer = os.clock() - start_time
	if timer >= 0.00 then
		local offs = {
			x = after.x - before.x,
			y = after.y - before.y,
			z = after.z - before.z,
			w = after.w - before.w
		}

		result_vec4.x = result_vec4.x + ( (offs.x / duration) * timer )
		result_vec4.y = result_vec4.y + ( (offs.y / duration) * timer )
		result_vec4.z = result_vec4.z + ( (offs.z / duration) * timer )
		result_vec4.w = result_vec4.w + ( (offs.w / duration) * timer )
	end
	return result_vec4
end

function plural(n, forms) 
	n = math.abs(n) % 100
	if n % 10 == 1 and n ~= 11 then
		return forms[1]
	elseif 2 <= n % 10 and n % 10 <= 4 and (n < 10 or n >= 20) then
		return forms[2]
	end
	return forms[3]
end

function getTimeAfter(unix)
	local interval = os.time() - unix
	if interval < 86400 then -- 1 day
		return '???????'
	elseif interval < 604800 then -- 1 week
		local days = math.floor(interval / 86400)
		local text = plural(days, {'????', '???', '????'})
		return ('%s %s ?????'):format(days, text)
	elseif interval < 2592000 then -- 1 month
		local weeks = math.floor(interval / 604800)
		local text = plural(weeks, {'??????', '??????', '??????'})
		return ('%s %s ?????'):format(weeks, text)
	elseif interval < 31536000 then -- 1 year
		local months = math.floor(interval / 2592000)
		local text = plural(months, {'?????', '??????', '???????'})
		return ('%s %s ?????'):format(months, text)
	else -- 1+ years
		local years = math.floor(interval / 31536000)
		local text = plural(years, {'???', '????', '???'})
		return ('%s %s ?????'):format(years, text)
	end
end

function log(text, tag)
	print(string.format("%s[%s]: %s%s", sc, (tag or "Info"), wc, text))
end

function helpCommands()
	if imgui.BeginPopupModal(u8("??? ??????? ???????"), _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
		imgui.PushFont(font[20])
		imgui.CenterTextColoredRGB(mc..'??? ????????? ??????? ? ????????? ??????')
		imgui.PopFont()
		imgui.Spacing()
		imgui.TextColoredRGB(sc..'??????? ? ????:')
		imgui.SetCursorPosX(20)
		imgui.BeginGroup()
			imgui.TextColoredRGB(mc..'/bank{SSSSSS} - ???????? ???? ??????? (???? "BB" ??? ???-???)')
			imgui.TextColoredRGB(mc..'/ustav{SSSSSS} - ????? ?? ? ????????? ????')
			imgui.TextColoredRGB(mc..'/ro [text]{SSSSSS} - ?? ??? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/rbo [text]{SSSSSS} - ????? ??? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/uninvite [id] [???????]{SSSSSS} - ?????????? ?????????? ? ?? ??????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/giverank [id] [????]{SSSSSS} - ?????? ????? ?????????? ? ?? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/fwarn [id] [???????]{SSSSSS} - ?????? ???????? ?????????? ? ?? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/blacklist [id] [???????]{SSSSSS} - ????????? ? ?? ????? ? ?? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/unfwarn [id]{SSSSSS} - ?????? ???????? ?????????? ? ?? ?????????? (9+ ????)')
			imgui.TextColoredRGB(mc..'/kip{SSSSSS} - ??????? ??????? ?????? ?????????? ?? ?????')
		imgui.EndGroup()
		imgui.Spacing()
		imgui.TextColoredRGB(sc..'????????? ??????:')
		imgui.SetCursorPosX(20)
		imgui.BeginGroup()
			imgui.TextColoredRGB(mc..'??? + Q{SSSSSS} - ???? ?????????????? ? ????????')
			imgui.TextColoredRGB(mc..'??? + G{SSSSSS} - ??????? ?? ????? ? ???????? ?.?.?')
			imgui.TextColoredRGB(mc..'??? + R{SSSSSS} - ???????? ???? ??? ???? {select_id}/{select_name}')
		imgui.EndGroup()
		imgui.Spacing()
		imgui.SetCursorPosX((imgui.GetWindowWidth() - 150) / 2)
		if imgui.Button(u8'???????##???????', imgui.ImVec2(150, 20)) then 
			imgui.CloseCurrentPopup()
		end 
		imgui.EndPopup()
	end
end

function checkData()
	local dir = getWorkingDirectory() .. '\\BHelper'
	if not doesDirectoryExist(dir) then
		if createDirectory(dir) then
			log(string.format('??????? ?????????? %s', dir), "??????????")
		end
	end

	log('???????? ??????? ??????..', "??????????")
	if not doesFileExist(lect_path) then
		lections = lections_default
		local file = io.open(lect_path, "w")
		file:write(encodeJson(lections))
		file:close()
		log('???? ?????? ?? ??????, ?????? ????', "??????????")
	else
		local file = io.open(lect_path, "r")
		lections = decodeJson(file:read('*a'))
		file:close()
	end

	local files = {
		['????? ??.txt'] = charter_default,
		['????????????.txt'] = lending_default,
		['???????? ???????.txt'] = HRsystem_default,
		['??????? ?????????.txt'] = Promotion_default
	}
	for name, text in pairs(files) do 
		if not doesFileExist(dir .. '\\' .. name) then
			log(string.format('?????? ???? ?%s?', name), "??????????")
			local file = io.open(dir .. '\\' .. name, "w")
			file:write(text)
			file:close()
		end
	end
	files = nil
	return true
end

function imgui.ToggleButton(str_id, bool)
	local rBool = false

	if LastActiveTime == nil then
		LastActiveTime = {}
	end
	if LastActive == nil then
		LastActive = {}
	end

	local function ImSaturate(f)
		return f < 0.0 and 0.0 or (f > 1.0 and 1.0 or f)
	end
	
	local p = imgui.GetCursorScreenPos()
	local draw_list = imgui.GetWindowDrawList()

	local height = imgui.GetTextLineHeightWithSpacing()
	local width = height * 1.55
	local radius = height * 0.50
	local ANIM_SPEED = 0.15
	local butPos = imgui.GetCursorPos()

	if imgui.InvisibleButton(str_id, imgui.ImVec2(width, height)) then
		bool.v = not bool.v
		rBool = true
		LastActiveTime[tostring(str_id)] = os.clock()
		LastActive[tostring(str_id)] = true
	end

	imgui.SetCursorPos(imgui.ImVec2(butPos.x + width + 8, butPos.y + 2.5))
	imgui.Text( str_id:gsub('##.+', '') )

	local t = bool.v and 1.0 or 0.0

	if LastActive[tostring(str_id)] then
		local time = os.clock() - LastActiveTime[tostring(str_id)]
		if time <= ANIM_SPEED then
			local t_anim = ImSaturate(time / ANIM_SPEED)
			t = bool.v and t_anim or 1.0 - t_anim
		else
			LastActive[tostring(str_id)] = false
		end
	end

	local col_cr, col_bg
	if bool.v then
		local bAct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
		col_cr = imgui.GetColorU32(imgui.ImVec4(bAct.x, bAct.y, bAct.z, 1.00))
		col_bg = imgui.GetColorU32(imgui.ImVec4(bAct.x, bAct.y, bAct.z, 0.50))
	else
		col_cr = imgui.GetColorU32(imgui.ImVec4(0.5, 0.5, 0.5, 1.00))
		col_bg = imgui.GetColorU32(imgui.ImVec4(0.5, 0.5, 0.5, 0.50))
	end

	draw_list:AddRectFilled(imgui.ImVec2(p.x, p.y + (height / 6)), imgui.ImVec2(p.x + width - 1.0, p.y + (height - (height / 6))), col_bg, 5.0)
	draw_list:AddCircleFilled(imgui.ImVec2(p.x + radius + t * (width - radius * 2.0), p.y + radius), radius - 0.75, col_cr)

	return rBool
end

changelog = {
	[20] = {
		version = '20',
		comment = '',
		date = os.time({day = '11', month = '11', year = '2021'}),
		log = {
			"????????? ????????? ??????? Casa-Grande (18)",
		},
		patches = {
			show = true,
			info = {}
		}
	},
	[19] = {
		version = '19',
		comment = '',
		date = os.time({day = '25', month = '7', year = '2021'}),
		log = {
			'? ????? ?????? "????? ??????????" ???????? ??????? ?????????? ??????? ???????? ?????????. ??? ???? ????????? ? ??????????? ??? ????????? ?????????, ? ??? ?? ?????? ?????? ?????????',
			'???????? ????? ?????? ??????????? ? ?????????? ????? ?????????????? ? ????????? -> ????????? ?????????/??????? (?? ????????? 2.5 ???????)',
			'????????? ?????? ???????? Bank-Helper? ? ????????? -> ? ???????',
			'?????? ??? ?????????? ??????????? (fontAwesome ? ???????? ????????? ??????)',
			'????????? ??????????? ????????????? ??????? ??????? ??????????',
			'????????? (?????????????) ????????? ?? ??????? ???? ???????'
		},
		patches = {
			show = false,
			info = {
				'??????????? ? ?????????',
				'????????? ??????? Show-Low (17)'
			}
		}
	},
	[18] = {
		version = '18',
		comment = '',
		date = os.time({day = '25', month = '5', year = '2021'}),
		log = {
			'?????? ? ?????? ?????? ??????????. ?????? ??? ??????? ????, ?????????? ??????.',
			'??????? ?????????? ????????? ?? ????? ? ????. ??? ?? ?????? ?? ????? ????????? ????????? ? ??????????',
			'????? ? ?????? ??????? ???????. ??????? ????? ?????????? ??????? ??????'
		},
		patches = {
			show = false,
			info = {
				'?????????? ????????? ?????????????? ??????',
				'??????????? ? ?????????'
			}
		}
	},
	[17] = {
		version = '17',
		comment = '',
		date = os.time({day = '2', month = '5', year = '2021'}),
		log = {
			'????????? ???????? ?????? ??? ????????????? ???? ???????, ??? ????? ??????? ??? ???????????',
			{
				title = '???????????? ??????? ?????????? ??????',
				show = false,
				more = {
					'?) ??????????? ????????? ???? ?????? ????? ?? ?????? ?? ????',
					'?) ??? ?????? ??????? ???????, ??? ?????? ??? ???????? ? ??????, ? ?? ?? ????? ?????????',
					'?) ??????????? ?????????? ??????????????? ?????? ? ????? ??????',
					'?) ??????????? ??????? ???, ? ??????? ????? ???????? ?????? (???????, /r ? /rb)',
					'?) ??????????? ????????????? ??????',
					'?) ?????? ??????????? ?? ?????????? "LuaFileSystem"'
				}
			},
			'????? ?????? ???? ?????? ????????? (changelog\'?)',
			'??????? ???? ??????? ????????? ????????? ?????????',
			'?????? ??? ???????? ???? ??????? ?? ??????????? "Ҹ????" ? "???????"',
			'??????? ??????? ??????? ?????????? ? ???? ? ??????? ????',
			'?????????? ??????? ??????? ?????? ???????. ?????? ?????? ????, ? ?? ?????????????? ?? ?????? ? ???????.',
			'?????? ??????????? ?? ??????? ??????????? ??? ???????',
			'?????? ??????????? ?? Notify.lua',
			'?????????? ???????? ??????????? "???????????" ?????',
			'?????? ?? ?????? ??????? ??????, ????????? ?? ???????????, ?????? ????? ?? ???? ? ?????????? ????????',
			'?????? ? ?????????? ?? ????? ????????? ???????? ????????? (?? ?????????, ?????? ???? ? ?.?)',
			'??????? ?????? ???????? ????????????. ?????? ??? ?? ?????? ??????? ?? ??????????? ????? ??????? ??????',
			'???????? ??????? /uval ??-?? ????????????',
			'????? ??????? ???-???????????. ?????? ??????? ? ???? ????? ?????? ? ??? ??? ???????? ?????.',
			'??? ????? ???-???? ? ????? ??? ?????? ?? ???????? ???????? ??? ??? N, ??? ?? ??????? ???? ????',
		},
		patches = {
			show = false,
			info = {
				'???? ????? ? ?????? /fwarn ? /blacklist',
				'????????? ????????? ?????? ??????? "Gilbert"'
			}
		}
	},
	[16] = {
		version = '16',
		comment = '',
		date = os.time({day = '3', month = '1', year = '2021'}),
		log = {
			'????????? ????????? 15-?? ??????? (Payson)',
			'?????? ??????????? ????????? ????????? ??? ?????? ???????'
		},
		patches = {
			show = false,
			info = {
				'????????? ???? ??????? ??? ????????? ?? ????? ?? ??????'
			}
		}
	},
	[15] = {
		version = '15',
		comment = '',
		date = os.time({day = '20', month = '11', year = '2020'}),
		log = {
			'????? "??????? ????", ? ????? ? ?????? ??? ??????? ? ??????? ?? ???????',
			'????????? ???, ????? ??? ????? ???? "?? ??????????"',
			'??????? ?????????? ??????? ???????? ?? ?????? ??? ??????? ???????',
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[14] = {
		version = '14',
		comment = '',
		date = os.time({day = '7', month = '11', year = '2020'}),
		log = {
			'????????? ????????? 14-?? ??????? ??????? (??????????, ?? ??????-???)',
			'????? ????????? ??????????? ????????? ? ??????? ???????',
		},
		patches = {
			show = false,
			info = {
				'???-???? ?????? ?????????'
			}
		}
	},
	[13] = {
		version = '13',
		comment = '',
		date = os.time({day = '16', month = '10', year = '2020'}),
		log = {
			'????? ????? ? ???? ???? ????????? ??-??? ??????? ????????, ????????? ??????? ?? ???? ? ??? (???????? ? 5+ ?????)',
			'???????? ???????? ?? ??????? ????? (???? ????) ??? ???????? ??? + Q',
			'? ???? ???????????? GOV-?????, ????? ???????? ??? ??????????? ? /d ???',
			'?????-׸???? "????? ???????" ???????? ?? ????? ??????',
			'??????? ?????????? ?????????',
			'??????? ?????? ????????????? ? ?????????? ????? PIN-???? ????? ?????????? ?????'
		},
		patches = {
			show = false,
			info = {
				'????????? ??????? ? ??????????? ?? ?????????? ?????? + ???????? ????? ??????'
			}
		}
	},
	[12] = {
		version = '12',
		comment = '',
		date = os.time({day = '3', month = '9', year = '2020'}),
		log = {
			'????? ???????????',
			'????????? ??? ????????? ?? ??? ?????????? ??????',
			'??????? ??????? ?????? ????????? ????? ?????? ???????????. ????? ? ??? ???????????? ? ???????? (????????: 1.000.000 ?????? 1000000)',
			'??????? /unfwarn, /fwarn ?????? ???????? ?????? ? 9 ?????',
			'?????????? ???? ?????????, ??????? ??????? ??????. ?????? ?? ??? ? ?????? ????????? ???????? ? ?? ????????'
		},
		patches = {
			show = false,
			info = {
				'???? ???? ? ?????????? ??????????? ?????????'
			}
		}
	},
	[11] = {
		version = '11',
		comment = '',
		date = os.time({day = '12', month = '8', year = '2020'}),
		log = {
			'??????, ????? ??????????? /jobprogress ??????, ? ??? ??????? ?? ???? (?? ????????? ?????? ?????? ?? ??????????? ??? ?????, ? ?? ???????, ??????? ?? ?? ???????? ??? ??? :/)',
			'?????? ?????? ?????????? ?? ????? ????? ????????? ? ??????????',
			'???? ? ?????????? ?????? ???????????? ??? ??????? ?????????????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[10] = {
		version = '10',
		comment = '',
		date = os.time({day = '25', month = '7', year = '2020'}),
		log = {
			{
				title = '?????????? ?????? ??? ???????????? ???????',
				show = false,
				more = {
					'?) ????????? ?????????? ??????? ?????????? ?????? ? ?????????! ???????? ??? ????????? ??????? ??????????? ??????? ? ????',
					'?) ??????? ???????? ??????? ?????????? ???????',
					'?) ?????????? ??????????? ??????? (????)'
				}
			},
			'?????? ????? GOV-????? ?? ???? ???????????? ??????????? ????? ??????????',
			'???????????? ? ???????? Cosmo ?????? ????? ??????? ??????? ???? ???? ? ???? ???????????',
			'????????? ??? ? ?????????? ?????? ? ??????? "???????????"',
			'? /bank - ????????? - ????? ????????? ????????? ??????? "??????? ????"',
			'?????? ?????? ?????????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[9] = {
		version = '9',
		comment = '',
		date = os.time({day = '11', month = '7', year = '2020'}),
		log = {
			{
				title = '?????? ???? ?? ?????? ??????? Cosmo (????????: Bob_Cosmo), ? ??? ????? ????????? ??????????',
				show = false,
				more = {
					'?) ??? ??? ? ???? ??????????? ?????????? ?????? ??????!',
					'?) ? ?????? ????? ???????? ??????? /ro, /rbo',
					'P.S. ??????? ????? ??????????..'
				}
			},
			{
				title = '? ??????? ?????? ?????? ????????? ???????',
				show = false,
				more = {
					'Members ?? ??????',
					'?????? ??????? ? ???????? ???? ???????, ?? ??? ????? ?????? ???????????? ???? ?????? ?????????? ?????????',
					'???? /premium',
				}
			},
			'????????? ???????? ?????? ?? ?????????? ??????????? ???????',
			'?? ?? ????? ??????????????! ??? ??? ??????? ?????????? ? ????? ?????? ? ?????????? - "???????????". ??? ??? ??? ??????? ? ???? ????????? ???????? ????????? ????? ??????? ????? ???????. ??? ??????? ?? ??????? "???????????" ??????? ????????????? ????, ? ??????? ????? ???, ??? ???? ?????????? ? ???? ???????',
			'?????? ? ???? ?????????????? (??? + Q) ???? ????? ??????? ?? ?????, ??? ??? ????? ??? ??? ??????, ? ?? ???? ?????? ?????? ??? ????? ??? + G',
			'? ?????????? ??????? ????? ??????? ???????, ? ??????? ????? ?????????? ?????????? (?? ????????? ?.?.?)',
			'????? ????-???????? /expel',
			'????????? ????? ???????? ???? ??????? - "?????? ???????"',
			'???? ?????? ??????????? ????? ??????? ??????? ? ????????? ??????????? ?????????? ?? ???? ?????',
			'?????? ?????? ????? ??????????? ??????, ???? ?? ?? ??????? Arizona RP',
			'????? ????? ?????? ???????????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[8] = {
		version = '8',
		comment = '',
		date = os.time({day = '27', month = '6', year = '2020'}),
		log = {
			'?????? ?? ?????? ? ??????????? ?? ????? ?????? ??????????? ????? ??????????, ? ???????????, ????? ????????? ????? ????',
			'?????? ?????? ?? ????? ????????, ???? ?? ?? ???????? ? ?????',
			'?????????? ??????? ????????? ????? ????????',
			'?????????? ??????? ???????? ??????????? ??? /premium',
			'???????? ?????? ?????? ??????? ?? /members, ??? ?? ??? ?????????? ??? ??? ??????, ?????? ???????? ???? /members, ?????? ??? ??? ??????? ?? ???',
			'??????? ??????? ????????? ??????, ?????? ??? ?????? ??????? ???????, ? ??? ?? ????? ??????? ????????? ? ??? ? ???? ????????',
			'???????? ???? /time ?? ??????? F9, ????????? ????? ? ??????????',
			'???????? ??????? ????????: ???????????? ????? ?????? 300.000$ (????????), ?????? ????? ?? ?????? ?????? ??????? ?????????? ??????? ????????????, ????????????? ???????? ??, ???? ??????? ???? ????????????.txt ? ????? /moonloader/BHelper',
			'???? ????????? ????????? ?? ??????? ? ????, ? ??? ?? ????????? ?? ??????????? ????? ????????? ? ??????? sampfuncs, ??? ?? ?? ?????? ?????? ???',
			'???? ???? ???????, ????? ? 1-4 ?????? ??? ??????? ???? ? ????? ?????, ???????? ????????? "???? ? ????? ???????? ? 5-?? ?????"',
			'?????????? ?????? ?????????',
			'??????? ??????????????? ???? /premium, ?????? ??? ???? ??????????????? ??????? ?????????? ?????? ?? ?????? ??????????',
			'???????? ? ?????? ?????? ???????????? ????????? ????? ???????????? ???',
			'??? @id ?????? ?????????? ?????? ??? ??????, ??? ??? ???????. ????????: "@343, ??? ?? ???????????" - "Jeffy, ??? ?? ???????????"',
			'?????????? ???????? ????? ???????, ?????? ?????????? ? ????? ????, ????? ???????? ? ????????, ??? ???? ?????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[7] = {
		version = '7',
		comment = '',
		date = os.time({day = '20', month = '6', year = '2020'}),
		log = {
			'????????? ?????? ??????????, ????? ?????? ?? ????? (????????? ????? ? /bank - ????????? - ????? ?????????)',
			'???????? ?????????????? ?????? ????? ???????? /kip (??????????? ????? ??????????)',
			'????? 3dText, ????? ????????? ?????, ?????? ?? ?????? ???????? ?????. ?????? ?? ??????? ? ?????? ?????????? (????? ????)',
			'?????? ??? ???????? ? /bankmenu (??? + Q) ???????????? ?? ??????. ???????? ?????? ?????? ???? ?? ????? ?????? ?????? "?????? ??????", ? ?????? ?? ????????',
			'????????? ???? ? /premium ??? ?????????? ????-?????????',
			'????????? ??????? /unblacklist [id]',
			'?????? ??? {screen} ???????? ??? ?????. ?????? ?????????????: "??????????, ?????? ? ??????? ??? ?????????? {screen}" (?????? ???????????? ????????????? ????? ????????, ? {screen} ?? ?????????? ? ???)',
			'????????????? ????????? ?????, ?????? ?? ?????? ????? ??? ???? ???????? ????? ????????',
			'????????? ????-????????? ?????????????? ????????? (fAwesome, lfs), ? ?????? ?? ??????????',
			'????????? ???, ????? ?????? ???? ?????? ?????? ")" "))" "(" "((" "xD" ":D" ???????? "? ????????". ?????? ??? ???????? ?? ??',
			'??? ??????? ? ???????????? ?????? ???? ?????, ? ??????? ?????????? ??? ?????????, ??????????, ?????? ????????? ? ??????. ????? ??????? ??? ?????????? ??????? ????????',
			'???????? ????? /members, ?? ???????? ? 5-??? ????? ? ??????? /bank -> ??. ??????',
			'????????? ????? ???????? ???????? ????? ?????????? ??? ???????? ????? ???????????? ? ???????. ????????: /bank -> ????????? -> ????????? ??????',
			'?????????? ???? ? ???????, ?? ???, ???????? ????????? ??? ?? "??????????" ??????? ??????????. ?? ????? "??????", ?? ????? ????? ??????????, ??????? ????? ????????? ???????? ? ?????????? 10-15 ??????, ??? ?? ?? ????????'
		},
		patches = {
			show = false,
			info = {
				'?????? ???????????',
				'????? ????????? ????? members\'a',
				'?????????? ???? ? ???????? /invite',
			}
		}
	},
	[6] = {
		version = '6',
		comment = '',
		date = os.time({day = '14', month = '6', year = '2020'}),
		log = {
			'????????? ??????????? ? ???? ??????, ?????? ????????? ????????? ????? ????????? ? ???',
			'??? 9-10 ?????? ????????? ???? ???????????? GOV ?????. ????? ??? ????? ?? ??????? "??????? ??????"',
			'? ???? ?? ?????? ????????? ???? ?????? ??????, ?????? ??? ???? ?????? ?? ??????? /premium',
			'???????? ??? ?????????? ??? ?????? ? ???????????. ?????? ? ???? ????? ????????? /ro ? /rbo'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[5] = {
		version = '5',
		comment = '',
		date = os.time({day = '10', month = '6', year = '2020'}),
		log = {
			'???? ?????? ?????? ??????????? (9+), ??? ????????? ?????? ???????? - /premium',
			'?????????? ????????? ?????????',
			'?????????? ????????? ????',
			'??????? ????????? ??? ???????: /blacklist, /giverank',
			'? ?????????? ??????? ????? ?????????? ??????? "????-?????". ??? ??????? ????????????? ??????? ? /time ??? ???? ?????????, ??????????, ?? ? ?.?.',
			'??? ?? ? ?????????? ????? ??????? ASI-?????? "Screenshot" ?? MISTER_GONWIK\'a. ?? ????????? ?????? ????????? ??? ?????????',
			'???????? ????? ??? ??? ??????? - {screen}. ????? ???????????? ? ????/????????. ????????: /giverank 228 9 {screen}, ??????? ???????? ???????, ? ????? ??? ????????? ?? ? /time'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[4] = {
		version = '4',
		comment = '',
		date = os.time({day = '6', month = '6', year = '2020'}),
		log = {
			'?????? ???????? ?? ???????? ????????? ??? ??????? ???????????? ??? + G (??????? ?? ?????), ????? ?????? ??? ???????? ???????????, ? ???????? ?????????? ??? ?????????????',
			'?????? ??? ???? ? ?????????? ??????? ????????????? ?????????????.',
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[3] = {
		version = '3',
		comment = '',
		date = os.time({day = '3', month = '6', year = '2020'}),
		log = {
			'???? ??? ???? ???? 8-???, ?? ??? ????????? ????????? ?????????????, ??? ??? ?????????? ?? ????? ???????????? ??, ??? ?? ??????? ????? ? ?????????, ? ????????????, ??? ?? ??????? ????????????, ??? ?? ?? ??? ?????? (??????? ? ?????)',
			'???????? ????? ? ?????????? "? ???????" - ????????? ?????????????? ??????????, ????? ?? ???????? ? ????',
			'????? ????????? ? ???? ??? ???????? ??????? (5+ ????) ? ???? /bank',
			'???????? ?? ????????????? (5+ ????) ? ????????? ??. ?????? (/bank). ?????? ? ????? ???????????: "?????? ??" ? "??????? ??", ? ???????? ??? ??????? ??? ??????? ? ????????????, ? ??? ?? ??? ???, ???? ????????? ?????????????. ??? ?????? ???????? ?? ׸????? ?????? ??? ?? ???? ??? ???????, ???? ???????? ?????? ?????? ?? ???????? ? ???? ?????',
			'????????? ??????? /invite (9+ ????), ????????? ????????? ??? ?? ?????????????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[2] = {
		version = '2',
		comment = '',
		date = os.time({day = '29', month = '5', year = '2020'}),
		log = {
			'???????? ????? ???? ????????? ? "?????????? ?????????/???????"',
			'???? ???? ????? ? ??????? ?????????? ??????????? ???????? "{SSSSSS}"',
			'????????? ????????? ????????? ??????, ???? ?? ?? ???????? ??????? ????? ?? ???????',
			'????????? ??????? /uninvite, ?????? ????????? ????????? ??? ?? ?????????????'
		},
		patches = {
			show = false,
			info = {}
		}
	},
	[1] = {
		version = '1',
		comment = '??????? ?? ?????? Noa Shelby, Bruno Quinzsy, Markus Quinzsy',
		date = os.time({day = '25', month = '5', year = '2020'}),
		log = {
			'????? ???????, ???????? ????-????????????',
		},
		patches = {
			show = false,
			info = {}
		}
	},
}

charter_default = [[????? 1. ????? ?????????.
1.1. ????? ???????????? ????? - ??? ????????????????????? ???????????????? ???????????? ??????????? ????????.
1.2. ????? ????? ???? ?????????????? ?????? ????? ???? ??? ??????????? ????????? ?????????? ??????????? ???? ???????? ????????? ? ???.
1.3. ????? ???????? ?????????????? ?????? ? ??????? ?????????? ?? ??????????? ??????? ?????.
1.4. ?? ????????, ???????????? ?????? ??????????? ??????????? ????? ????? ?????? ?????????????? ????????? ?????? ?????????? ? ???? ????????, ?????????, ??????????.

????? 2. ??????????? ???????????.
2.1. ?????? ????????? ?????? ????? ? ????????? ????? ??????????? ? ??????? ?? ????????.
2.2. ?????? ????????? ?????? ????????? ???? ??????????? ??????????? ???????????.
2.3. ?????? ????????? ?????? ????????? ???????????, ???????? ?????? ? ???? ???????? ????. ??? ???????????? ????????? ????? ??????? ? ???????????? ? ??????????? ?????????????????.
2.4. ?????? ????????? ?????? ????????? ? ?????? ???????????? ???????????? ????????????.
2.5. ?????? ????????? ?????? ????????? ???????? ?????????? ???????????.
2.6. ?????? ????????? ?????? ???? ????????? ? ????.????? ?? ????? ?????????? ????? ??????????? ????????????.
2.7. ?????? ????????? ?????? ????????????? ?? ????? ??????????? ? ??????? ????.

????? 3. ?????????? ? ????? ???????????.
3.1. ?????????? ?????? ????? ????? ????????? ?????????? ???? ???? ??????????? ???????? ?????????.
3.2. ?????????? ????? ????? ???????? ????? ?????????? ?? ??????????? ???????? ??????? ?????.
3.3. ?????????? ???????????? ?????, ? ??????: ?????????? ?????? ??????????, ?????????? ??????? ??????????, ?????????, ??????????? ?????????, ??????? ???????? ????? ????? ???????????? ?????? ???????????? ? ????????? ?????.
3.4. ?????????? ????????????? ????? ????? ?? ?????? ????? ??? ???????? ???????.
3.5. ?????????? ????? ????? ?? ?????? ? ???????????? ? ??????????? ???????? ????????.
3.5.1. ?????? ????? ???? ???? ?????? ???? ??? ? ?????.
3.5.2. ?????? ? ?????????? ????? [2] ????? ????? ?? ?????? ? ??????? ?????? (???? ??????????? ????).
2.5.3. ??????? ?????????? ?????, ?????????? ?????? ??????????, ?????????? ??????? ??????????, ????????? ????? ????? ?? ?????? ? ??????? ???? ??????????? ????.
2.5.4. ????????? ????? ????? ????? ?? ?????? ? ??????? ???? ????.

????? 4. ??????????? ???????????.
4.1. ??????????? ???????????? ????? ?????? ????????? ????????: ???????????, ???????? ??????, ????? ???????????? ?????, ????????? ? ???????????????? ???????.
4.2. ??????????? ???????????? ????? ?????? ????????? ?????????????? ??? ?????? ??????? ?????? ?????????????? ??????.
4.3. ??????????? ???????????? ????? ?????? ????????? ??????????? ??????? ????
4.3.1. ??????? ???? ? ?????? ??? ? 9:00 ?? 20:00.
4.3.2. ??????? ???? ? ???????? ? 10:00 ?? 19:00.
4.3.3. ????????? ??????? ? 14:00 ?? 15:00 ?????????.
4.4 ??????????? ???????????? ????? ?????? ????????? ???????????? ?????????? ??????????? ? ?????? ?????.
4.5. ??????????? ???????????? ????? ?????? ????????? ????????? ????????????? ??????.
4.5.1 ??????????? ???????????? ????? ????????? ???????? ???? ????.
4.5.2. ??????????: ?? ????????? ?????????? ? ????????????????? ??????? ??? ??????? ????????.
4.6. ??????????? ???????????? ????? ?????? ????????? ??????.
4.7. ??????????? ???????????? ????? ?????? ????????? ???????? ???????? ???????.
4.7.1 ??????????? ???????????? ????? ????????? ??????????? ????????????? ????????
4.8. ??????????? ???????????? ????? ?????? ????????? ?????????? ??????????.
4.9. ??????????? ???????????? ????? ?????? ????????? ?????????? ???????? ???????? ???????????.
4.10. ??????????? ???????????? ????? ?????? ????????? ?????? ?? ???? ??????????.
4.10.1. ??????????: Ҹ???? ???? ??????? ?????, ????, ???.
4.11. ??????????? ???????????? ????? ?????? ????????? ????????? ?????????????? ??????\???????? ????.
4.12. ??????????? ???????????? ????? ?????? ????????? ??????? ? ???????? ?? ?????????.
4.13. ??????????? ???????????? ????? ?????? ????????? ??????? ? ???????? ?? ???????? ???????.
4.14. ??????????? ???????????? ????? ?????? ????????? ???????? ?????????? ? ?????. ?????????? ? ??????.
4.15. ??????????? ???????????? ????? ?????? ????????? ??????? ? ???????? ?? ??????? ??????.
4.16. ??????????? ???????????? ????? ?????? ????????? ????????? ?????????? ???? ??? ??????? ???????.
4.17. ??????????? ???????????? ????? ?????? ????????? ????? ????? ?? ??????? ?????.
4.17.1. ?????? ? ?????????? ????? [1-4] ?? ????? ?????? ?????.
4.17.2. ??????? ?????????? ?????, ?????????? ?????? ??????????, ?????????? ??????? ??????????, [5-8] ?? ????? ?????? ?????.
4.17.3. ??????????? ????????? [9] ?? ????? ?????? ?????.

????? 5. ?????????? ? ?????.
5.1. ????? ?????????? ??????? ?? ?????????? ???????? ??????????? ????? (?? ????? ???? ?????).
5.2. ? ????? ??????????? ????????? ???????????? ????????? ?????????.
5.3. ? ????? ??????????? ????????? ???????????? ????? ?????.
5.4. ? ????? ??????????? ????????? ????? ?????????.
5.5. ? ????? ??????????? ????????? ???????????? ????? ? ?????.
5.6. ? ????? ??????????? ????????? ?????????? ??? ????.
5.7. ? ????? ????????? ?????? ??????????? ??????? ?????????? ???????????? ????????? ??????? ???????? ?????.
5.8. ???????? ??????????? ??????????? ?? ?????????? ????? ????? ?????????? ? ????????? ?????????? ?????? ? ????.
5.9. ?? ????????? ??????????? ? ????? ???????? ??????? ??????? ???????? ?????.

????? 6. ?????? ????????? ??? ?????????? ?????????? ? ?????????? ?????
6.1 ?????????? ?????? ????? ???????? ????????????? ?????????? ? ????????? ?????????? ?????? ? ???? (3+)
6.2 ?????????? ????? ????????? ??????????, ??????????? ?? ????????? ?????????? ?????? ? ???? (3+)
6.3 ????? ??????????? ???????? ????? ??????? ?????????? 20 ?????.
6.3.1 ???? ????????? ???????????? ????? ????? ????? ???????? ?????????? ?????? ???? ??? ? 25 ?????.
6.3 ????? ?????????????? ????????????? ????? ??????? ?????????? 30 ?????.
6.3.1 ???? ????????? ???????????? ????? ????? ????? ????????? ????????????? ??????????? ???? ??? ? 35 ?????.
6.4 ?? ???????????? ?????? ???? ??????????? ???? ??????????? ??????? ????????? ?????????? ????? ?? ????????? ?????????? ? ?????????.
6.4.1 ? ?????? ????????????? ????????? ???????????? ??????????? ???????? ?????? ??????????????.]]

HRsystem_default = [[{006AC2}???????? ???????{SSSSSS} - ??????? ??????? ??????? ?????????? ?? 
?????? ?????. ??????? ??????? - ??? ??? ????????????? 
???? ?? ????? ?????. ?????? ???? ?? ?? ?????? ???????
?? ?????????. ????????????? ????? ? 1 ?? 9 ????:
?
{006AC2}1 {SSSSSS}->{006AC2} 2 ???? {SSSSSS}- ???????????
{006AC2}2 {SSSSSS}->{006AC2} 3 ???? {SSSSSS}- 12 ?????
{006AC2}3 {SSSSSS}->{006AC2} 4 ???? {SSSSSS}- 24 ????
{006AC2}4 {SSSSSS}->{006AC2} 5 ???? {SSSSSS}- 24 ????
{006AC2}5 {SSSSSS}->{006AC2} 6 ???? {SSSSSS}- 48 ????? (2-? ?????)
{006AC2}6 {SSSSSS}->{006AC2} 7 ???? {SSSSSS}- 72 ???? (3-? ?????)
{006AC2}7 {SSSSSS}->{006AC2} 8 ???? {SSSSSS}- 120 ????? (5 ?????)
{006AC2}8 {SSSSSS}->{006AC2} 9 ???? {SSSSSS}- 144 ???? (6 ?????)
{006AC2}9 {SSSSSS}->{006AC2} 10 ???? {SSSSSS}- 360 ????? (15 ?????)]]

Promotion_default = [[{0088C2}??????? ????????? ??? 1 - 7 ??????
C ??? 2020 ???? - ????????. ????? ???????? ?? ???? ??????????, ???????? ???? ??????
?
{0088C2}???????? [7] -> ???. ????????? [8]
??????????? ?? ?????? ????????? 120 ????? {868686}(5 ????)
1. ????????? ?? ?????? 2 ???? {868686}(????????? ?????? 10 ????? ? /time)
2. ???????? 30 ?????? ??????? {868686}(?? ????? ????????? 5 ??????; ??????????? /timestamp)
3. ?????? ?? 15-? ??????????????
4. ???????? 5 ??????????? ??? ???????
5. ????????? 5 ??????? {868686}(?? ???????; /me /do /todo ??????? 10 ?? ?????????)
?
{0088C2}???.????????? [8] -> ???????? ????? [9]
??????????? ?? ?????? ????????? 144 ???? {868686}(6 ????)
????????? ?????
???????????? ? ?????? ?? ???? ????????? ???????????? ?????
??????????: ????? ?? 9-? ???? ???????? ?????? ?? 8-?, ?? ? ??????????? ?????? ??????????????]]

lending_default = [[?? {009000}5.000${FFFFFF} ?? {009000}25.000${FFFFFF}:
????????? ? ????? ?? 3-? ?? 5-?? ???
????? ???????? ??????? ???
????? ????????????????? ???? 30-??
---
?? {009000}25.000${FFFFFF} ?? {009000}50.000${FFFFFF}:
????????? ? ????? ?? 5-?? ?? 8-?? ???
????? ???????? ??????? ???
????? ????????????????? ???? 40-??
---
?? {009000}50.000${FFFFFF} ?? {009000}100.000${FFFFFF}:
????????? ? ????? ?? 8-?? ?? 11-?? ???
????? ???????? ? ?????
?? ????? ??????? ? ????????.
????? ???????? ??????? ???
????? ????????????????? ???? 50-??
---
?? {009000}75.000${FFFFFF} ?? {009000}100.000${FFFFFF}:
????????? ? ????? ?? 11-?? ???
????? ???????? ? ?????
?? ????? ??????? ? ????????
????? ???????? ??????? ???
????? ????????????????? ???? 70-??
---
?? {009000}100.000${FFFFFF} ?? {009000}175.000${FFFFFF}:
????????? ? ????? ?? 15-???
?? ????? ??????? ? ????????
????? ???????? ??????? ???
????? ????????????????? ???? 75-??
????? ???????? ? ?????
---
?? {009000}175.000${FFFFFF} ?? {009000}300.000${FFFFFF}:
????????? ? ????? ?? 17-???
?? ????? ??????? ? ????????
????? ???????? ??????? ???
????? ????????????????? ???? 80-??
????? ???????? ? ?????.]]

lections_default = {
	active = { bool = false, name = nil, handle = nil },
	data = {
		{
			name = "??????? ??? ???????????",
			text = {
				"?????? ?? ??????????? ?????? ? ???, ??? ?????? ????????? ????? ????????? ????? ? ??????? ?????",
				"?????? ?????????, ??????? ?? ????? ?????? ??????????? ? ??????? ?????, ????? ??????? ? ?????",
				"???? ??????? ????? - ??? ???? ????. ??? ?????? ???? ?????? ? ???????????",
				"??? ??, ?? ??? ? ?? ????? ????? ?? ?????? ???? ????? ???? ???????????, ????? ?????",
				"?? ?? ?????? ????????? ??? ????? ??? ?????????????? ????. ?????? ? ?? ?????-????",
				"???? ???????. ?????? ????????"
			}
		},
		{
			name = "????????? ????????? ?? ???",
			text = {
				"?????? ? ???????? ??? ?????? ?? ???? \"????????? ????????? ?? ???\"",
				"???? ?? ?????? ????????? ?? ?????? ?????, ???????? ???????? ??? ?????? ? ????????",
				"?? ????? ???????? ?????????? ? ???????? ???????, ??? ?????????????",
				"????? ?????????, ??? ??????? ????????? ????? ? ?????? ????? ?????? ?????????!",
				"????? ??????????? ???????? ??????????, ? ????? ??????? ??????? ?? ??? ?????????????.",
				"???? ???????. ?????? ????????."
			}
		},
		{
			name = "????????? ?? ????????",
			text = {
				"?????? ????????? ?????? ?? ???? \"????????? ?? ???????? ?? ?????????\"",
				"??-??????, ? ??????? ?? ????????? ????????????? ?? \"??\"",
				"??-??????, ?????????? ??????? ?? ????? \"???\", \"??????\", \"????????\"",
				"?? ?? ? ???? ?????? ?? \"???????\" ??? ????? ??? ????????!",
				"??? ????? ?? ?????????, ??? ?? ????? ???????? ?????????? ?? ??????",
				"????????? ??? ???????? ???????.",
				"??????????? ??????????? ???????? ???? ??????? ????? ????, ??? ???????????",
				"???? ??????? ?? ????????, ?????? ????????"
			}
		},
		{
			name = "??????? ?????? ?????",
			text = {
				"??????????? ?????? ????????? ????????? ???????? ?????? ?????",
				"????, ????????????? ?????? ?????? ?? ?????, ??? ???? ??? ?? ??????? ? ?? ?????",
				"???????? ???? ? ??? ????? ????? ????????? ??? ?????????? ???????????",
				"?? ??? ???? ??????????? ????? ?????? ??????????",
				"?????? ???????????? ??????? ?? ?? ?????????? ? ??? ???????",
				"?????? ?????? ?????? ????? ??????? ?? ??????????? ??????? ?????? ?????",
				"?????? ????????, ??????? ?? ????????"
			}
		},
		{
			name = "??????? ????????? ??? ???????",
			text = {
				"?????? ? ??????? ??? ?????? ?? ???? \"??????? ????????? ??? ???????\"",
				"???? ? ??????? ?????, ?? ??? ?????? ???????, ?? ?????? ?????, ?? ??????:",
				"?????? - ??? ??????????? ?????? ?? ????????? ??????",
				"?????? - ?????????? ?? ????? ?????? ? ???????, ???? ????? ??? ???????????",
				"?????? - ??????????? ??????? ???????? ???????? ? ????????? ??",
				"????????? - ??????? ??????? ??????? ????????",
				"????? - ?? ???????? ??????? ????????? ? ??????? ?????? ? ??????? ????????",
				"??? ??, ?? ????? ??????????, ? ??? ?????? ????? ??????? ????? ? ???????",
				"???? ???????, ?????? ????????"
			}
		},
		{
			name = "???????????? ? ?????????",
			text = {
				"?????? ? ??????? ??? ?????? ?? ???? \"???????????? ? ?????????\"",
				"?????????? ?????? ?????????? ???????? ?? ??????? ???. ??????????",
				"???????????? ???????: ?? ????????? ???????? ? ?? ????????????? ? ???? ?? ??? ?????",
				"???????????????. ? ????? ?????? ??? ????? ??? ??? ????? ????????.",
				"?? ??????? ??? ?????? ???? ?????. ????? ????? ??? ????????? ??-?? ?????-?? ?????????",
				"??????? ?? ????????, ?????? ????????"
			}
		}
	}
}

fa = {
	['ICON_FA_NOTES_MEDICAL'] = "\xef\x92\x81",
 	['ICON_FA_CLOUD_SHOWERS_HEAVY'] = "\xef\x9d\x80",
 	['ICON_FA_SMS'] = "\xef\x9f\x8d",
 	['ICON_FA_COPY'] = "\xef\x83\x85",
 	['ICON_FA_CHEVRON_CIRCLE_RIGHT'] = "\xef\x84\xb8",
 	['ICON_FA_CROSSHAIRS'] = "\xef\x81\x9b",
 	['ICON_FA_BROADCAST_TOWER'] = "\xef\x94\x99",
 	['ICON_FA_EXTERNAL_LINK_SQUARE_ALT'] = "\xef\x8d\xa0",
 	['ICON_FA_SMOKING'] = "\xef\x92\x8d",
 	['ICON_FA_KISS_BEAM'] = "\xef\x96\x97",
 	['ICON_FA_CHESS_BISHOP'] = "\xef\x90\xba",
 	['ICON_FA_TV'] = "\xef\x89\xac",
 	['ICON_FA_CROP_ALT'] = "\xef\x95\xa5",
 	['ICON_FA_TH'] = "\xef\x80\x8a",
 	['ICON_FA_RECYCLE'] = "\xef\x86\xb8",
 	['ICON_FA_SMILE'] = "\xef\x84\x98",
 	['ICON_FA_FAX'] = "\xef\x86\xac",
 	['ICON_FA_DRAFTING_COMPASS'] = "\xef\x95\xa8",
 	['ICON_FA_USER_INJURED'] = "\xef\x9c\xa8",
 	['ICON_FA_SCREWDRIVER'] = "\xef\x95\x8a",
 	['ICON_FA_DHARMACHAKRA'] = "\xef\x99\x95",
 	['ICON_FA_PRINT'] = "\xef\x80\xaf",
 	['ICON_FA_BABY_CARRIAGE'] = "\xef\x9d\xbd",
 	['ICON_FA_CARET_UP'] = "\xef\x83\x98",
 	['ICON_FA_SCHOOL'] = "\xef\x95\x89",
 	['ICON_FA_SORT_NUMERIC_UP'] = "\xef\x85\xa3",
 	['ICON_FA_TRUCK_LOADING'] = "\xef\x93\x9e",
 	['ICON_FA_LIST'] = "\xef\x80\xba",
 	['ICON_FA_UPLOAD'] = "\xef\x82\x93",
 	['ICON_FA_LAPTOP_MEDICAL'] = "\xef\xa0\x92",
 	['ICON_FA_EXPAND_ARROWS_ALT'] = "\xef\x8c\x9e",
 	['ICON_FA_ADJUST'] = "\xef\x81\x82",
 	['ICON_FA_VENUS'] = "\xef\x88\xa1",
 	['ICON_FA_HEADING'] = "\xef\x87\x9c",
 	['ICON_FA_ARROW_DOWN'] = "\xef\x81\xa3",
 	['ICON_FA_BICYCLE'] = "\xef\x88\x86",
 	['ICON_FA_TIRED'] = "\xef\x97\x88",
 	['ICON_FA_AIR_FRESHENER'] = "\xef\x97\x90",
 	['ICON_FA_BACON'] = "\xef\x9f\xa5",
 	['ICON_FA_SYNC'] = "\xef\x80\xa1",
 	['ICON_FA_PAPER_PLANE'] = "\xef\x87\x98",
 	['ICON_FA_VOLLEYBALL_BALL'] = "\xef\x91\x9f",
 	['ICON_FA_RIBBON'] = "\xef\x93\x96",
 	['ICON_FA_HAND_LIZARD'] = "\xef\x89\x98",
 	['ICON_FA_CLOCK'] = "\xef\x80\x97",
 	['ICON_FA_SUN'] = "\xef\x86\x85",
 	['ICON_FA_FILE_POWERPOINT'] = "\xef\x87\x84",
 	['ICON_FA_MICROCHIP'] = "\xef\x8b\x9b",
 	['ICON_FA_TRASH_RESTORE_ALT'] = "\xef\xa0\xaa",
 	['ICON_FA_GRADUATION_CAP'] = "\xef\x86\x9d",
 	['ICON_FA_ANGLE_DOUBLE_DOWN'] = "\xef\x84\x83",
 	['ICON_FA_INFO_CIRCLE'] = "\xef\x81\x9a",
 	['ICON_FA_TAGS'] = "\xef\x80\xac",
 	['ICON_FA_FILE_ALT'] = "\xef\x85\x9c",
 	['ICON_FA_EQUALS'] = "\xef\x94\xac",
 	['ICON_FA_DIRECTIONS'] = "\xef\x97\xab",
 	['ICON_FA_FILE_INVOICE'] = "\xef\x95\xb0",
 	['ICON_FA_SEARCH'] = "\xef\x80\x82",
 	['ICON_FA_BIBLE'] = "\xef\x99\x87",
 	['ICON_FA_FLASK'] = "\xef\x83\x83",
 	['ICON_FA_CALENDAR_TIMES'] = "\xef\x89\xb3",
 	['ICON_FA_GREATER_THAN_EQUAL'] = "\xef\x94\xb2",
 	['ICON_FA_SLIDERS_H'] = "\xef\x87\x9e",
 	['ICON_FA_EYE_SLASH'] = "\xef\x81\xb0",
 	['ICON_FA_BIRTHDAY_CAKE'] = "\xef\x87\xbd",
 	['ICON_FA_FEATHER_ALT'] = "\xef\x95\xab",
 	['ICON_FA_DNA'] = "\xef\x91\xb1",
 	['ICON_FA_BASEBALL_BALL'] = "\xef\x90\xb3",
 	['ICON_FA_HOSPITAL'] = "\xef\x83\xb8",
 	['ICON_FA_COINS'] = "\xef\x94\x9e",
 	['ICON_FA_HRYVNIA'] = "\xef\x9b\xb2",
 	['ICON_FA_TEMPERATURE_HIGH'] = "\xef\x9d\xa9",
 	['ICON_FA_FONT_AWESOME_LOGO_FULL'] = "\xef\x93\xa6",
 	['ICON_FA_PASSPORT'] = "\xef\x96\xab",
 	['ICON_FA_TAG'] = "\xef\x80\xab",
 	['ICON_FA_SHOPPING_CART'] = "\xef\x81\xba",
 	['ICON_FA_AWARD'] = "\xef\x95\x99",
 	['ICON_FA_WINDOW_RESTORE'] = "\xef\x8b\x92",
 	['ICON_FA_PHONE'] = "\xef\x82\x95",
 	['ICON_FA_FLAG'] = "\xef\x80\xa4",
 	['ICON_FA_STETHOSCOPE'] = "\xef\x83\xb1",
 	['ICON_FA_DICE_D6'] = "\xef\x9b\x91",
 	['ICON_FA_OUTDENT'] = "\xef\x80\xbb",
 	['ICON_FA_LONG_ARROW_ALT_RIGHT'] = "\xef\x8c\x8b",
 	['ICON_FA_PIZZA_SLICE'] = "\xef\xa0\x98",
 	['ICON_FA_ADDRESS_CARD'] = "\xef\x8a\xbb",
 	['ICON_FA_PARAGRAPH'] = "\xef\x87\x9d",
 	['ICON_FA_MALE'] = "\xef\x86\x83",
 	['ICON_FA_HISTORY'] = "\xef\x87\x9a",
 	['ICON_FA_HAMBURGER'] = "\xef\xa0\x85",
 	['ICON_FA_SEARCH_PLUS'] = "\xef\x80\x8e",
 	['ICON_FA_FIRE_ALT'] = "\xef\x9f\xa4",
 	['ICON_FA_LIFE_RING'] = "\xef\x87\x8d",
 	['ICON_FA_SHARE'] = "\xef\x81\xa4",
 	['ICON_FA_ALIGN_JUSTIFY'] = "\xef\x80\xb9",
 	['ICON_FA_BATTERY_THREE_QUARTERS'] = "\xef\x89\x81",
 	['ICON_FA_OBJECT_UNGROUP'] = "\xef\x89\x88",
 	['ICON_FA_BRIEFCASE'] = "\xef\x82\xb1",
 	['ICON_FA_OIL_CAN'] = "\xef\x98\x93",
 	['ICON_FA_THERMOMETER_FULL'] = "\xef\x8b\x87",
 	['ICON_FA_PLANE'] = "\xef\x81\xb2",
 	['ICON_FA_HEARTBEAT'] = "\xef\x88\x9e",
 	['ICON_FA_UNLINK'] = "\xef\x84\xa7",
 	['ICON_FA_WINDOW_MAXIMIZE'] = "\xef\x8b\x90",
 	['ICON_FA_HEADPHONES'] = "\xef\x80\xa5",
 	['ICON_FA_STEP_BACKWARD'] = "\xef\x81\x88",
 	['ICON_FA_DRAGON'] = "\xef\x9b\x95",
 	['ICON_FA_MICROPHONE_SLASH'] = "\xef\x84\xb1",
 	['ICON_FA_USER_PLUS'] = "\xef\x88\xb4",
 	['ICON_FA_WRENCH'] = "\xef\x82\xad",
 	['ICON_FA_AMBULANCE'] = "\xef\x83\xb9",
 	['ICON_FA_ETHERNET'] = "\xef\x9e\x96",
 	['ICON_FA_EGG'] = "\xef\x9f\xbb",
 	['ICON_FA_WIND'] = "\xef\x9c\xae",
 	['ICON_FA_UNIVERSAL_ACCESS'] = "\xef\x8a\x9a",
 	['ICON_FA_BURN'] = "\xef\x91\xaa",
 	['ICON_FA_HAND_HOLDING_HEART'] = "\xef\x92\xbe",
 	['ICON_FA_DICE_ONE'] = "\xef\x94\xa5",
 	['ICON_FA_KEYBOARD'] = "\xef\x84\x9c",
 	['ICON_FA_CHECK_DOUBLE'] = "\xef\x95\xa0",
 	['ICON_FA_HEADPHONES_ALT'] = "\xef\x96\x8f",
 	['ICON_FA_BATTERY_HALF'] = "\xef\x89\x82",
 	['ICON_FA_PROJECT_DIAGRAM'] = "\xef\x95\x82",
 	['ICON_FA_PRAY'] = "\xef\x9a\x83",
 	['ICON_FA_GOPURAM'] = "\xef\x99\xa4",
 	['ICON_FA_GRIN_TEARS'] = "\xef\x96\x88",
 	['ICON_FA_SORT_AMOUNT_UP'] = "\xef\x85\xa1",
 	['ICON_FA_COFFEE'] = "\xef\x83\xb4",
 	['ICON_FA_TABLET_ALT'] = "\xef\x8f\xba",
 	['ICON_FA_GRIN_BEAM_SWEAT'] = "\xef\x96\x83",
 	['ICON_FA_HAND_POINT_RIGHT'] = "\xef\x82\xa4",
 	['ICON_FA_MAGIC'] = "\xef\x83\x90",
 	['ICON_FA_CHARGING_STATION'] = "\xef\x97\xa7",
 	['ICON_FA_GRIN_TONGUE'] = "\xef\x96\x89",
 	['ICON_FA_VOLUME_OFF'] = "\xef\x80\xa6",
 	['ICON_FA_SAD_TEAR'] = "\xef\x96\xb4",
 	['ICON_FA_CARET_RIGHT'] = "\xef\x83\x9a",
 	['ICON_FA_BONG'] = "\xef\x95\x9c",
 	['ICON_FA_BONE'] = "\xef\x97\x97",
 	['ICON_FA_ELLIPSIS_V'] = "\xef\x85\x82",
 	['ICON_FA_BALANCE_SCALE'] = "\xef\x89\x8e",
 	['ICON_FA_FISH'] = "\xef\x95\xb8",
 	['ICON_FA_SPIDER'] = "\xef\x9c\x97",
 	['ICON_FA_CAMPGROUND'] = "\xef\x9a\xbb",
 	['ICON_FA_CARET_SQUARE_UP'] = "\xef\x85\x91",
 	['ICON_FA_RUPEE_SIGN'] = "\xef\x85\x96",
 	['ICON_FA_ASSISTIVE_LISTENING_SYSTEMS'] = "\xef\x8a\xa2",
 	['ICON_FA_POUND_SIGN'] = "\xef\x85\x94",
 	['ICON_FA_ANKH'] = "\xef\x99\x84",
 	['ICON_FA_BATTERY_QUARTER'] = "\xef\x89\x83",
 	['ICON_FA_HAND_PEACE'] = "\xef\x89\x9b",
 	['ICON_FA_SURPRISE'] = "\xef\x97\x82",
 	['ICON_FA_FILE_PDF'] = "\xef\x87\x81",
 	['ICON_FA_VIDEO_SLASH'] = "\xef\x93\xa2",
 	['ICON_FA_SUBWAY'] = "\xef\x88\xb9",
 	['ICON_FA_HORSE'] = "\xef\x9b\xb0",
 	['ICON_FA_WINE_BOTTLE'] = "\xef\x9c\xaf",
 	['ICON_FA_BOOK_READER'] = "\xef\x97\x9a",
 	['ICON_FA_COOKIE'] = "\xef\x95\xa3",
 	['ICON_FA_MONEY_BILL'] = "\xef\x83\x96",
 	['ICON_FA_CHEVRON_DOWN'] = "\xef\x81\xb8",
 	['ICON_FA_CAR_SIDE'] = "\xef\x97\xa4",
 	['ICON_FA_FILTER'] = "\xef\x82\xb0",
 	['ICON_FA_FOLDER_OPEN'] = "\xef\x81\xbc",
 	['ICON_FA_SIGNATURE'] = "\xef\x96\xb7",
 	['ICON_FA_SNOWBOARDING'] = "\xef\x9f\x8e",
 	['ICON_FA_THUMBTACK'] = "\xef\x82\x8d",
 	['ICON_FA_DICE_TWO'] = "\xef\x94\xa8",
 	['ICON_FA_LAUGH_WINK'] = "\xef\x96\x9c",
 	['ICON_FA_BREAD_SLICE'] = "\xef\x9f\xac",
 	['ICON_FA_TEXT_HEIGHT'] = "\xef\x80\xb4",
 	['ICON_FA_VOLUME_MUTE'] = "\xef\x9a\xa9",
 	['ICON_FA_VOTE_YEA'] = "\xef\x9d\xb2",
 	['ICON_FA_QRCODE'] = "\xef\x80\xa9",
 	['ICON_FA_MERCURY'] = "\xef\x88\xa3",
 	['ICON_FA_USER_ASTRONAUT'] = "\xef\x93\xbb",
 	['ICON_FA_SORT_AMOUNT_DOWN'] = "\xef\x85\xa0",
 	['ICON_FA_SORT_DOWN'] = "\xef\x83\x9d",
 	['ICON_FA_COMPACT_DISC'] = "\xef\x94\x9f",
 	['ICON_FA_PERCENTAGE'] = "\xef\x95\x81",
 	['ICON_FA_COMMENT_MEDICAL'] = "\xef\x9f\xb5",
 	['ICON_FA_STORE'] = "\xef\x95\x8e",
 	['ICON_FA_COMMENT_DOTS'] = "\xef\x92\xad",
 	['ICON_FA_SMILE_WINK'] = "\xef\x93\x9a",
 	['ICON_FA_HOTEL'] = "\xef\x96\x94",
 	['ICON_FA_PEPPER_HOT'] = "\xef\xa0\x96",
 	['ICON_FA_USER_EDIT'] = "\xef\x93\xbf",
 	['ICON_FA_DUMPSTER_FIRE'] = "\xef\x9e\x94",
 	['ICON_FA_CLOUD_SUN_RAIN'] = "\xef\x9d\x83",
 	['ICON_FA_GLOBE_ASIA'] = "\xef\x95\xbe",
 	['ICON_FA_VIAL'] = "\xef\x92\x92",
 	['ICON_FA_STROOPWAFEL'] = "\xef\x95\x91",
 	['ICON_FA_DATABASE'] = "\xef\x87\x80",
 	['ICON_FA_TREE'] = "\xef\x86\xbb",
 	['ICON_FA_SHOWER'] = "\xef\x8b\x8c",
 	['ICON_FA_DRUM_STEELPAN'] = "\xef\x95\xaa",
 	['ICON_FA_FILE_UPLOAD'] = "\xef\x95\xb4",
 	['ICON_FA_MEDKIT'] = "\xef\x83\xba",
 	['ICON_FA_MINUS'] = "\xef\x81\xa8",
 	['ICON_FA_SHEKEL_SIGN'] = "\xef\x88\x8b",
 	['ICON_FA_BELL_SLASH'] = "\xef\x87\xb6",
 	['ICON_FA_MAIL_BULK'] = "\xef\x99\xb4",
 	['ICON_FA_MOUNTAIN'] = "\xef\x9b\xbc",
 	['ICON_FA_COUCH'] = "\xef\x92\xb8",
 	['ICON_FA_CHESS'] = "\xef\x90\xb9",
 	['ICON_FA_FILE_EXPORT'] = "\xef\x95\xae",
 	['ICON_FA_SIGN_LANGUAGE'] = "\xef\x8a\xa7",
 	['ICON_FA_SNOWFLAKE'] = "\xef\x8b\x9c",
 	['ICON_FA_PLAY'] = "\xef\x81\x8b",
 	['ICON_FA_HEADSET'] = "\xef\x96\x90",
 	['ICON_FA_SQUARE_ROOT_ALT'] = "\xef\x9a\x98",
 	['ICON_FA_CHART_BAR'] = "\xef\x82\x80",
 	['ICON_FA_WAVE_SQUARE'] = "\xef\xa0\xbe",
 	['ICON_FA_CHART_AREA'] = "\xef\x87\xbe",
 	['ICON_FA_EURO_SIGN'] = "\xef\x85\x93",
 	['ICON_FA_CHESS_KING'] = "\xef\x90\xbf",
 	['ICON_FA_MOBILE'] = "\xef\x84\x8b",
 	['ICON_FA_BOX_OPEN'] = "\xef\x92\x9e",
 	['ICON_FA_DOG'] = "\xef\x9b\x93",
 	['ICON_FA_FUTBOL'] = "\xef\x87\xa3",
 	['ICON_FA_LIRA_SIGN'] = "\xef\x86\x95",
 	['ICON_FA_LIGHTBULB'] = "\xef\x83\xab",
 	['ICON_FA_BOMB'] = "\xef\x87\xa2",
 	['ICON_FA_MITTEN'] = "\xef\x9e\xb5",
 	['ICON_FA_TRUCK_MONSTER'] = "\xef\x98\xbb",
 	['ICON_FA_ARROWS_ALT_H'] = "\xef\x8c\xb7",
 	['ICON_FA_CHESS_ROOK'] = "\xef\x91\x87",
 	['ICON_FA_FIRE_EXTINGUISHER'] = "\xef\x84\xb4",
 	['ICON_FA_BOOKMARK'] = "\xef\x80\xae",
 	['ICON_FA_ARROWS_ALT_V'] = "\xef\x8c\xb8",
 	['ICON_FA_ICICLES'] = "\xef\x9e\xad",
 	['ICON_FA_FONT'] = "\xef\x80\xb1",
 	['ICON_FA_CAMERA_RETRO'] = "\xef\x82\x83",
 	['ICON_FA_BLENDER'] = "\xef\x94\x97",
 	['ICON_FA_THUMBS_DOWN'] = "\xef\x85\xa5",
 	['ICON_FA_GAMEPAD'] = "\xef\x84\x9b",
 	['ICON_FA_COPYRIGHT'] = "\xef\x87\xb9",
 	['ICON_FA_JEDI'] = "\xef\x99\xa9",
 	['ICON_FA_HOCKEY_PUCK'] = "\xef\x91\x93",
 	['ICON_FA_STOP_CIRCLE'] = "\xef\x8a\x8d",
 	['ICON_FA_BEZIER_CURVE'] = "\xef\x95\x9b",
 	['ICON_FA_FOLDER'] = "\xef\x81\xbb",
 	['ICON_FA_RSS'] = "\xef\x82\x9e",
 	['ICON_FA_COLUMNS'] = "\xef\x83\x9b",
 	['ICON_FA_GLASS_CHEERS'] = "\xef\x9e\x9f",
 	['ICON_FA_GRIN_WINK'] = "\xef\x96\x8c",
 	['ICON_FA_STOP'] = "\xef\x81\x8d",
 	['ICON_FA_MONEY_CHECK_ALT'] = "\xef\x94\xbd",
 	['ICON_FA_COMPASS'] = "\xef\x85\x8e",
 	['ICON_FA_TOOLBOX'] = "\xef\x95\x92",
 	['ICON_FA_LIST_OL'] = "\xef\x83\x8b",
 	['ICON_FA_WINE_GLASS'] = "\xef\x93\xa3",
 	['ICON_FA_HORSE_HEAD'] = "\xef\x9e\xab",
 	['ICON_FA_USER_ALT_SLASH'] = "\xef\x93\xba",
 	['ICON_FA_USER_TAG'] = "\xef\x94\x87",
 	['ICON_FA_MICROSCOPE'] = "\xef\x98\x90",
 	['ICON_FA_BRUSH'] = "\xef\x95\x9d",
 	['ICON_FA_BAN'] = "\xef\x81\x9e",
 	['ICON_FA_BARS'] = "\xef\x83\x89",
 	['ICON_FA_CAR_CRASH'] = "\xef\x97\xa1",
 	['ICON_FA_ARROW_ALT_CIRCLE_DOWN'] = "\xef\x8d\x98",
 	['ICON_FA_MONEY_BILL_ALT'] = "\xef\x8f\x91",
 	['ICON_FA_JOURNAL_WHILLS'] = "\xef\x99\xaa",
 	['ICON_FA_CHALKBOARD_TEACHER'] = "\xef\x94\x9c",
 	['ICON_FA_PORTRAIT'] = "\xef\x8f\xa0",
 	['ICON_FA_HAMMER'] = "\xef\x9b\xa3",
 	['ICON_FA_RETWEET'] = "\xef\x81\xb9",
 	['ICON_FA_HOURGLASS'] = "\xef\x89\x94",
 	['ICON_FA_HAND_PAPER'] = "\xef\x89\x96",
 	['ICON_FA_SUBSCRIPT'] = "\xef\x84\xac",
 	['ICON_FA_DONATE'] = "\xef\x92\xb9",
 	['ICON_FA_GLASS_MARTINI_ALT'] = "\xef\x95\xbb",
 	['ICON_FA_CODE_BRANCH'] = "\xef\x84\xa6",
 	['ICON_FA_NOT_EQUAL'] = "\xef\x94\xbe",
 	['ICON_FA_MEH'] = "\xef\x84\x9a",
 	['ICON_FA_LIST_ALT'] = "\xef\x80\xa2",
 	['ICON_FA_USER_COG'] = "\xef\x93\xbe",
 	['ICON_FA_PRESCRIPTION'] = "\xef\x96\xb1",
 	['ICON_FA_TABLET'] = "\xef\x84\x8a",
 	['ICON_FA_PENCIL_RULER'] = "\xef\x96\xae",
 	['ICON_FA_CREDIT_CARD'] = "\xef\x82\x9d",
 	['ICON_FA_ARCHWAY'] = "\xef\x95\x97",
 	['ICON_FA_HARD_HAT'] = "\xef\xa0\x87",
 	['ICON_FA_MAP_MARKER_ALT'] = "\xef\x8f\x85",
 	['ICON_FA_COG'] = "\xef\x80\x93",
 	['ICON_FA_HANUKIAH'] = "\xef\x9b\xa6",
 	['ICON_FA_SHUTTLE_VAN'] = "\xef\x96\xb6",
 	['ICON_FA_MONEY_CHECK'] = "\xef\x94\xbc",
 	['ICON_FA_BELL'] = "\xef\x83\xb3",
 	['ICON_FA_CALENDAR_DAY'] = "\xef\x9e\x83",
 	['ICON_FA_TINT_SLASH'] = "\xef\x97\x87",
 	['ICON_FA_PLANE_DEPARTURE'] = "\xef\x96\xb0",
 	['ICON_FA_USER_CHECK'] = "\xef\x93\xbc",
 	['ICON_FA_CHURCH'] = "\xef\x94\x9d",
 	['ICON_FA_SEARCH_MINUS'] = "\xef\x80\x90",
 	['ICON_FA_PALLET'] = "\xef\x92\x82",
 	['ICON_FA_TINT'] = "\xef\x81\x83",
 	['ICON_FA_STAMP'] = "\xef\x96\xbf",
 	['ICON_FA_KAABA'] = "\xef\x99\xab",
 	['ICON_FA_ALIGN_RIGHT'] = "\xef\x80\xb8",
 	['ICON_FA_QUOTE_RIGHT'] = "\xef\x84\x8e",
 	['ICON_FA_BEER'] = "\xef\x83\xbc",
 	['ICON_FA_GRIN_ALT'] = "\xef\x96\x81",
 	['ICON_FA_SORT_NUMERIC_DOWN'] = "\xef\x85\xa2",
 	['ICON_FA_FIRE'] = "\xef\x81\xad",
 	['ICON_FA_FAST_FORWARD'] = "\xef\x81\x90",
 	['ICON_FA_MAP_MARKED_ALT'] = "\xef\x96\xa0",
 	['ICON_FA_PENCIL_ALT'] = "\xef\x8c\x83",
 	['ICON_FA_USERS_COG'] = "\xef\x94\x89",
 	['ICON_FA_CARET_SQUARE_DOWN'] = "\xef\x85\x90",
 	['ICON_FA_CRUTCH'] = "\xef\x9f\xb7",
 	['ICON_FA_OBJECT_GROUP'] = "\xef\x89\x87",
 	['ICON_FA_ANCHOR'] = "\xef\x84\xbd",
 	['ICON_FA_HAND_POINT_LEFT'] = "\xef\x82\xa5",
 	['ICON_FA_USER_TIMES'] = "\xef\x88\xb5",
 	['ICON_FA_CALCULATOR'] = "\xef\x87\xac",
 	['ICON_FA_DIZZY'] = "\xef\x95\xa7",
 	['ICON_FA_KISS_WINK_HEART'] = "\xef\x96\x98",
 	['ICON_FA_FILE_MEDICAL'] = "\xef\x91\xb7",
 	['ICON_FA_SWIMMING_POOL'] = "\xef\x97\x85",
 	['ICON_FA_WEIGHT_HANGING'] = "\xef\x97\x8d",
 	['ICON_FA_VR_CARDBOARD'] = "\xef\x9c\xa9",
 	['ICON_FA_FAST_BACKWARD'] = "\xef\x81\x89",
 	['ICON_FA_SATELLITE'] = "\xef\x9e\xbf",
 	['ICON_FA_USER'] = "\xef\x80\x87",
 	['ICON_FA_MINUS_CIRCLE'] = "\xef\x81\x96",
 	['ICON_FA_CHESS_PAWN'] = "\xef\x91\x83",
 	['ICON_FA_CALENDAR_MINUS'] = "\xef\x89\xb2",
 	['ICON_FA_CHESS_BOARD'] = "\xef\x90\xbc",
 	['ICON_FA_LANDMARK'] = "\xef\x99\xaf",
 	['ICON_FA_SWATCHBOOK'] = "\xef\x97\x83",
 	['ICON_FA_HOTDOG'] = "\xef\xa0\x8f",
 	['ICON_FA_SNOWMAN'] = "\xef\x9f\x90",
 	['ICON_FA_LAPTOP'] = "\xef\x84\x89",
 	['ICON_FA_TORAH'] = "\xef\x9a\xa0",
 	['ICON_FA_FROWN_OPEN'] = "\xef\x95\xba",
 	['ICON_FA_USER_LOCK'] = "\xef\x94\x82",
 	['ICON_FA_AD'] = "\xef\x99\x81",
 	['ICON_FA_USER_CIRCLE'] = "\xef\x8a\xbd",
 	['ICON_FA_DIVIDE'] = "\xef\x94\xa9",
 	['ICON_FA_HANDSHAKE'] = "\xef\x8a\xb5",
 	['ICON_FA_CUT'] = "\xef\x83\x84",
 	['ICON_FA_HIKING'] = "\xef\x9b\xac",
 	['ICON_FA_STREET_VIEW'] = "\xef\x88\x9d",
 	['ICON_FA_GREATER_THAN'] = "\xef\x94\xb1",
 	['ICON_FA_PASTAFARIANISM'] = "\xef\x99\xbb",
 	['ICON_FA_MINUS_SQUARE'] = "\xef\x85\x86",
 	['ICON_FA_SAVE'] = "\xef\x83\x87",
 	['ICON_FA_COMMENT_DOLLAR'] = "\xef\x99\x91",
 	['ICON_FA_TRASH_ALT'] = "\xef\x8b\xad",
 	['ICON_FA_PUZZLE_PIECE'] = "\xef\x84\xae",
 	['ICON_FA_MENORAH'] = "\xef\x99\xb6",
 	['ICON_FA_CLOUD_SUN'] = "\xef\x9b\x84",
 	['ICON_FA_USER_FRIENDS'] = "\xef\x94\x80",
 	['ICON_FA_FILE_MEDICAL_ALT'] = "\xef\x91\xb8",
 	['ICON_FA_ARROW_LEFT'] = "\xef\x81\xa0",
 	['ICON_FA_BOXES'] = "\xef\x91\xa8",
 	['ICON_FA_THERMOMETER_EMPTY'] = "\xef\x8b\x8b",
 	['ICON_FA_EXCLAMATION_TRIANGLE'] = "\xef\x81\xb1",
 	['ICON_FA_GIFT'] = "\xef\x81\xab",
 	['ICON_FA_COGS'] = "\xef\x82\x85",
 	['ICON_FA_SIGNAL'] = "\xef\x80\x92",
 	['ICON_FA_SHAPES'] = "\xef\x98\x9f",
 	['ICON_FA_CLOUD_RAIN'] = "\xef\x9c\xbd",
 	['ICON_FA_ELLIPSIS_H'] = "\xef\x85\x81",
 	['ICON_FA_LESS_THAN_EQUAL'] = "\xef\x94\xb7",
 	['ICON_FA_CHEVRON_CIRCLE_LEFT'] = "\xef\x84\xb7",
 	['ICON_FA_MORTAR_PESTLE'] = "\xef\x96\xa7",
 	['ICON_FA_SITEMAP'] = "\xef\x83\xa8",
 	['ICON_FA_BUS_ALT'] = "\xef\x95\x9e",
 	['ICON_FA_ID_BADGE'] = "\xef\x8b\x81",
 	['ICON_FA_FIST_RAISED'] = "\xef\x9b\x9e",
 	['ICON_FA_BATTERY_FULL'] = "\xef\x89\x80",
 	['ICON_FA_CROWN'] = "\xef\x94\xa1",
 	['ICON_FA_EXCHANGE_ALT'] = "\xef\x8d\xa2",
 	['ICON_FA_SOCKS'] = "\xef\x9a\x96",
 	['ICON_FA_CASH_REGISTER'] = "\xef\x9e\x88",
 	['ICON_FA_REDO'] = "\xef\x80\x9e",
 	['ICON_FA_EXCLAMATION_CIRCLE'] = "\xef\x81\xaa",
 	['ICON_FA_COMMENTS'] = "\xef\x82\x86",
 	['ICON_FA_BRIEFCASE_MEDICAL'] = "\xef\x91\xa9",
 	['ICON_FA_CARET_SQUARE_RIGHT'] = "\xef\x85\x92",
 	['ICON_FA_PEN'] = "\xef\x8c\x84",
 	['ICON_FA_BACKSPACE'] = "\xef\x95\x9a",
 	['ICON_FA_SLASH'] = "\xef\x9c\x95",
 	['ICON_FA_HOT_TUB'] = "\xef\x96\x93",
 	['ICON_FA_SUITCASE_ROLLING'] = "\xef\x97\x81",
 	['ICON_FA_BATTERY_EMPTY'] = "\xef\x89\x84",
 	['ICON_FA_GLOBE_AFRICA'] = "\xef\x95\xbc",
 	['ICON_FA_SLEIGH'] = "\xef\x9f\x8c",
 	['ICON_FA_BOLT'] = "\xef\x83\xa7",
 	['ICON_FA_THERMOMETER_QUARTER'] = "\xef\x8b\x8a",
 	['ICON_FA_EYE'] = "\xef\x81\xae",
 	['ICON_FA_TROPHY'] = "\xef\x82\x91",
 	['ICON_FA_BRAILLE'] = "\xef\x8a\xa1",
 	['ICON_FA_PLUS'] = "\xef\x81\xa7",
 	['ICON_FA_LIST_UL'] = "\xef\x83\x8a",
 	['ICON_FA_SMOKING_BAN'] = "\xef\x95\x8d",
 	['ICON_FA_BATH'] = "\xef\x8b\x8d",
 	['ICON_FA_VOLUME_DOWN'] = "\xef\x80\xa7",
 	['ICON_FA_QUESTION_CIRCLE'] = "\xef\x81\x99",
 	['ICON_FA_FILE_CODE'] = "\xef\x87\x89",
 	['ICON_FA_GAVEL'] = "\xef\x83\xa3",
 	['ICON_FA_CANDY_CANE'] = "\xef\x9e\x86",
 	['ICON_FA_NETWORK_WIRED'] = "\xef\x9b\xbf",
 	['ICON_FA_CARET_SQUARE_LEFT'] = "\xef\x86\x91",
 	['ICON_FA_PLANE_ARRIVAL'] = "\xef\x96\xaf",
 	['ICON_FA_SHARE_SQUARE'] = "\xef\x85\x8d",
 	['ICON_FA_MEDAL'] = "\xef\x96\xa2",
 	['ICON_FA_THERMOMETER_HALF'] = "\xef\x8b\x89",
 	['ICON_FA_QUESTION'] = "\xef\x84\xa8",
 	['ICON_FA_CAR_BATTERY'] = "\xef\x97\x9f",
 	['ICON_FA_DOOR_CLOSED'] = "\xef\x94\xaa",
 	['ICON_FA_LEAF'] = "\xef\x81\xac",
 	['ICON_FA_USER_MINUS'] = "\xef\x94\x83",
 	['ICON_FA_MUSIC'] = "\xef\x80\x81",
 	['ICON_FA_GLOBE_EUROPE'] = "\xef\x9e\xa2",
 	['ICON_FA_HOUSE_DAMAGE'] = "\xef\x9b\xb1",
 	['ICON_FA_CHEVRON_RIGHT'] = "\xef\x81\x94",
 	['ICON_FA_GRIP_HORIZONTAL'] = "\xef\x96\x8d",
 	['ICON_FA_DICE_FOUR'] = "\xef\x94\xa4",
 	['ICON_FA_DEAF'] = "\xef\x8a\xa4",
 	['ICON_FA_REGISTERED'] = "\xef\x89\x9d",
 	['ICON_FA_WINDOW_CLOSE'] = "\xef\x90\x90",
 	['ICON_FA_LINK'] = "\xef\x83\x81",
 	['ICON_FA_YEN_SIGN'] = "\xef\x85\x97",
 	['ICON_FA_ATOM'] = "\xef\x97\x92",
 	['ICON_FA_LESS_THAN'] = "\xef\x94\xb6",
 	['ICON_FA_OTTER'] = "\xef\x9c\x80",
 	['ICON_FA_INFO'] = "\xef\x84\xa9",
 	['ICON_FA_MARS_DOUBLE'] = "\xef\x88\xa7",
 	['ICON_FA_CLIPBOARD_CHECK'] = "\xef\x91\xac",
 	['ICON_FA_SKULL'] = "\xef\x95\x8c",
 	['ICON_FA_GRIP_LINES'] = "\xef\x9e\xa4",
 	['ICON_FA_HOSPITAL_SYMBOL'] = "\xef\x91\xbe",
 	['ICON_FA_X_RAY'] = "\xef\x92\x97",
 	['ICON_FA_ARROW_UP'] = "\xef\x81\xa2",
 	['ICON_FA_MONEY_BILL_WAVE'] = "\xef\x94\xba",
 	['ICON_FA_DOT_CIRCLE'] = "\xef\x86\x92",
 	['ICON_FA_PAUSE_CIRCLE'] = "\xef\x8a\x8b",
 	['ICON_FA_IMAGES'] = "\xef\x8c\x82",
 	['ICON_FA_STAR_HALF'] = "\xef\x82\x89",
 	['ICON_FA_SPLOTCH'] = "\xef\x96\xbc",
 	['ICON_FA_STAR_HALF_ALT'] = "\xef\x97\x80",
 	['ICON_FA_SHIP'] = "\xef\x88\x9a",
 	['ICON_FA_BOOK_DEAD'] = "\xef\x9a\xb7",
 	['ICON_FA_CHECK'] = "\xef\x80\x8c",
 	['ICON_FA_RAINBOW'] = "\xef\x9d\x9b",
 	['ICON_FA_POWER_OFF'] = "\xef\x80\x91",
 	['ICON_FA_LEMON'] = "\xef\x82\x94",
 	['ICON_FA_GLOBE_AMERICAS'] = "\xef\x95\xbd",
 	['ICON_FA_PEACE'] = "\xef\x99\xbc",
 	['ICON_FA_THERMOMETER_THREE_QUARTERS'] = "\xef\x8b\x88",
 	['ICON_FA_WAREHOUSE'] = "\xef\x92\x94",
 	['ICON_FA_TRANSGENDER'] = "\xef\x88\xa4",
 	['ICON_FA_PLUS_SQUARE'] = "\xef\x83\xbe",
 	['ICON_FA_BULLSEYE'] = "\xef\x85\x80",
 	['ICON_FA_COOKIE_BITE'] = "\xef\x95\xa4",
 	['ICON_FA_USERS'] = "\xef\x83\x80",
 	['ICON_FA_TRANSGENDER_ALT'] = "\xef\x88\xa5",
 	['ICON_FA_ASTERISK'] = "\xef\x81\xa9",
 	['ICON_FA_STAR_OF_DAVID'] = "\xef\x9a\x9a",
 	['ICON_FA_PLUS_CIRCLE'] = "\xef\x81\x95",
 	['ICON_FA_CART_ARROW_DOWN'] = "\xef\x88\x98",
 	['ICON_FA_FLUSHED'] = "\xef\x95\xb9",
 	['ICON_FA_STORE_ALT'] = "\xef\x95\x8f",
 	['ICON_FA_PEOPLE_CARRY'] = "\xef\x93\x8e",
 	['ICON_FA_LONG_ARROW_ALT_DOWN'] = "\xef\x8c\x89",
 	['ICON_FA_SAD_CRY'] = "\xef\x96\xb3",
 	['ICON_FA_DIGITAL_TACHOGRAPH'] = "\xef\x95\xa6",
 	['ICON_FA_FILE_EXCEL'] = "\xef\x87\x83",
 	['ICON_FA_TEETH'] = "\xef\x98\xae",
 	['ICON_FA_HAND_SCISSORS'] = "\xef\x89\x97",
 	['ICON_FA_FILE_INVOICE_DOLLAR'] = "\xef\x95\xb1",
 	['ICON_FA_STEP_FORWARD'] = "\xef\x81\x91",
 	['ICON_FA_BACKWARD'] = "\xef\x81\x8a",
 	['ICON_FA_SCROLL'] = "\xef\x9c\x8e",
 	['ICON_FA_IGLOO'] = "\xef\x9e\xae",
 	['ICON_FA_CODE'] = "\xef\x84\xa1",
 	['ICON_FA_TRAM'] = "\xef\x9f\x9a",
 	['ICON_FA_TORII_GATE'] = "\xef\x9a\xa1",
 	['ICON_FA_SKIING'] = "\xef\x9f\x89",
 	['ICON_FA_CHAIR'] = "\xef\x9b\x80",
 	['ICON_FA_DUMBBELL'] = "\xef\x91\x8b",
 	['ICON_FA_ANGLE_DOUBLE_UP'] = "\xef\x84\x82",
 	['ICON_FA_ANGLE_DOUBLE_LEFT'] = "\xef\x84\x80",
 	['ICON_FA_MOSQUE'] = "\xef\x99\xb8",
 	['ICON_FA_COMMENTS_DOLLAR'] = "\xef\x99\x93",
 	['ICON_FA_FILE_PRESCRIPTION'] = "\xef\x95\xb2",
 	['ICON_FA_ANGLE_LEFT'] = "\xef\x84\x84",
 	['ICON_FA_ATLAS'] = "\xef\x95\x98",
 	['ICON_FA_PIGGY_BANK'] = "\xef\x93\x93",
 	['ICON_FA_DOLLY_FLATBED'] = "\xef\x91\xb4",
 	['ICON_FA_RANDOM'] = "\xef\x81\xb4",
 	['ICON_FA_PEN_ALT'] = "\xef\x8c\x85",
 	['ICON_FA_PRAYING_HANDS'] = "\xef\x9a\x84",
 	['ICON_FA_VOLUME_UP'] = "\xef\x80\xa8",
 	['ICON_FA_CLIPBOARD_LIST'] = "\xef\x91\xad",
 	['ICON_FA_GRIN_STARS'] = "\xef\x96\x87",
 	['ICON_FA_FOLDER_MINUS'] = "\xef\x99\x9d",
 	['ICON_FA_DEMOCRAT'] = "\xef\x9d\x87",
 	['ICON_FA_MAGNET'] = "\xef\x81\xb6",
 	['ICON_FA_VIHARA'] = "\xef\x9a\xa7",
 	['ICON_FA_GRIMACE'] = "\xef\x95\xbf",
 	['ICON_FA_CHECK_CIRCLE'] = "\xef\x81\x98",
 	['ICON_FA_SEARCH_DOLLAR'] = "\xef\x9a\x88",
 	['ICON_FA_LONG_ARROW_ALT_LEFT'] = "\xef\x8c\x8a",
 	['ICON_FA_CROW'] = "\xef\x94\xa0",
 	['ICON_FA_EYE_DROPPER'] = "\xef\x87\xbb",
 	['ICON_FA_CROP'] = "\xef\x84\xa5",
 	['ICON_FA_SIGN'] = "\xef\x93\x99",
 	['ICON_FA_ARROW_CIRCLE_DOWN'] = "\xef\x82\xab",
 	['ICON_FA_VIDEO'] = "\xef\x80\xbd",
 	['ICON_FA_DOWNLOAD'] = "\xef\x80\x99",
 	['ICON_FA_BOLD'] = "\xef\x80\xb2",
 	['ICON_FA_CARET_DOWN'] = "\xef\x83\x97",
 	['ICON_FA_CHEVRON_LEFT'] = "\xef\x81\x93",
 	['ICON_FA_HAMSA'] = "\xef\x99\xa5",
 	['ICON_FA_CART_PLUS'] = "\xef\x88\x97",
 	['ICON_FA_CLIPBOARD'] = "\xef\x8c\xa8",
 	['ICON_FA_SHOE_PRINTS'] = "\xef\x95\x8b",
 	['ICON_FA_PHONE_SLASH'] = "\xef\x8f\x9d",
 	['ICON_FA_REPLY'] = "\xef\x8f\xa5",
 	['ICON_FA_HOURGLASS_HALF'] = "\xef\x89\x92",
 	['ICON_FA_LONG_ARROW_ALT_UP'] = "\xef\x8c\x8c",
 	['ICON_FA_CHESS_KNIGHT'] = "\xef\x91\x81",
 	['ICON_FA_BARCODE'] = "\xef\x80\xaa",
 	['ICON_FA_DRAW_POLYGON'] = "\xef\x97\xae",
 	['ICON_FA_WATER'] = "\xef\x9d\xb3",
 	['ICON_FA_PAUSE'] = "\xef\x81\x8c",
 	['ICON_FA_WINE_GLASS_ALT'] = "\xef\x97\x8e",
 	['ICON_FA_GLASS_WHISKEY'] = "\xef\x9e\xa0",
 	['ICON_FA_BOX'] = "\xef\x91\xa6",
 	['ICON_FA_DIAGNOSES'] = "\xef\x91\xb0",
 	['ICON_FA_FILE_IMAGE'] = "\xef\x87\x85",
 	['ICON_FA_ARROW_CIRCLE_RIGHT'] = "\xef\x82\xa9",
 	['ICON_FA_TASKS'] = "\xef\x82\xae",
 	['ICON_FA_VECTOR_SQUARE'] = "\xef\x97\x8b",
 	['ICON_FA_QUOTE_LEFT'] = "\xef\x84\x8d",
 	['ICON_FA_MOBILE_ALT'] = "\xef\x8f\x8d",
 	['ICON_FA_USER_SHIELD'] = "\xef\x94\x85",
 	['ICON_FA_BLOG'] = "\xef\x9e\x81",
 	['ICON_FA_MARKER'] = "\xef\x96\xa1",
 	['ICON_FA_USER_TIE'] = "\xef\x94\x88",
 	['ICON_FA_TOOLS'] = "\xef\x9f\x99",
 	['ICON_FA_CLOUD'] = "\xef\x83\x82",
 	['ICON_FA_HAND_HOLDING_USD'] = "\xef\x93\x80",
 	['ICON_FA_CERTIFICATE'] = "\xef\x82\xa3",
 	['ICON_FA_CLOUD_DOWNLOAD_ALT'] = "\xef\x8e\x81",
 	['ICON_FA_ANGRY'] = "\xef\x95\x96",
 	['ICON_FA_FROG'] = "\xef\x94\xae",
 	['ICON_FA_CAMERA'] = "\xef\x80\xb0",
 	['ICON_FA_DICE_THREE'] = "\xef\x94\xa7",
 	['ICON_FA_MEMORY'] = "\xef\x94\xb8",
 	['ICON_FA_PEN_SQUARE'] = "\xef\x85\x8b",
 	['ICON_FA_SORT'] = "\xef\x83\x9c",
 	['ICON_FA_PLUG'] = "\xef\x87\xa6",
 	['ICON_FA_MOUSE_POINTER'] = "\xef\x89\x85",
 	['ICON_FA_ENVELOPE'] = "\xef\x83\xa0",
 	['ICON_FA_LAYER_GROUP'] = "\xef\x97\xbd",
 	['ICON_FA_TRAIN'] = "\xef\x88\xb8",
 	['ICON_FA_BULLHORN'] = "\xef\x82\xa1",
 	['ICON_FA_BABY'] = "\xef\x9d\xbc",
 	['ICON_FA_CONCIERGE_BELL'] = "\xef\x95\xa2",
 	['ICON_FA_CIRCLE'] = "\xef\x84\x91",
 	['ICON_FA_I_CURSOR'] = "\xef\x89\x86",
 	['ICON_FA_CAR'] = "\xef\x86\xb9",
 	['ICON_FA_CAT'] = "\xef\x9a\xbe",
 	['ICON_FA_WALLET'] = "\xef\x95\x95",
 	['ICON_FA_BOOK_MEDICAL'] = "\xef\x9f\xa6",
 	['ICON_FA_H_SQUARE'] = "\xef\x83\xbd",
 	['ICON_FA_HEART'] = "\xef\x80\x84",
 	['ICON_FA_LOCK_OPEN'] = "\xef\x8f\x81",
 	['ICON_FA_STREAM'] = "\xef\x95\x90",
 	['ICON_FA_LOCK'] = "\xef\x80\xa3",
 	['ICON_FA_CARROT'] = "\xef\x9e\x87",
 	['ICON_FA_SMILE_BEAM'] = "\xef\x96\xb8",
 	['ICON_FA_USER_NURSE'] = "\xef\xa0\xaf",
 	['ICON_FA_MICROPHONE_ALT'] = "\xef\x8f\x89",
 	['ICON_FA_SPA'] = "\xef\x96\xbb",
 	['ICON_FA_CHEVRON_CIRCLE_DOWN'] = "\xef\x84\xba",
 	['ICON_FA_FOLDER_PLUS'] = "\xef\x99\x9e",
 	['ICON_FA_CLOUD_MEATBALL'] = "\xef\x9c\xbb",
 	['ICON_FA_BOOK_OPEN'] = "\xef\x94\x98",
 	['ICON_FA_MAP'] = "\xef\x89\xb9",
 	['ICON_FA_COCKTAIL'] = "\xef\x95\xa1",
 	['ICON_FA_CLONE'] = "\xef\x89\x8d",
 	['ICON_FA_ID_CARD_ALT'] = "\xef\x91\xbf",
 	['ICON_FA_CHECK_SQUARE'] = "\xef\x85\x8a",
 	['ICON_FA_CHART_LINE'] = "\xef\x88\x81",
 	['ICON_FA_FILE_ARCHIVE'] = "\xef\x87\x86",
 	['ICON_FA_DOVE'] = "\xef\x92\xba",
 	['ICON_FA_MARS_STROKE'] = "\xef\x88\xa9",
 	['ICON_FA_ENVELOPE_OPEN'] = "\xef\x8a\xb6",
 	['ICON_FA_WHEELCHAIR'] = "\xef\x86\x93",
 	['ICON_FA_ROBOT'] = "\xef\x95\x84",
 	['ICON_FA_UNDO_ALT'] = "\xef\x8b\xaa",
 	['ICON_FA_TICKET_ALT'] = "\xef\x8f\xbf",
 	['ICON_FA_TRUCK'] = "\xef\x83\x91",
 	['ICON_FA_WON_SIGN'] = "\xef\x85\x99",
 	['ICON_FA_SUPERSCRIPT'] = "\xef\x84\xab",
 	['ICON_FA_TTY'] = "\xef\x87\xa4",
 	['ICON_FA_USER_MD'] = "\xef\x83\xb0",
 	['ICON_FA_ALIGN_LEFT'] = "\xef\x80\xb6",
 	['ICON_FA_TABLETS'] = "\xef\x92\x90",
 	['ICON_FA_MOTORCYCLE'] = "\xef\x88\x9c",
 	['ICON_FA_ANGLE_UP'] = "\xef\x84\x86",
 	['ICON_FA_BROOM'] = "\xef\x94\x9a",
 	['ICON_FA_TOILET_PAPER'] = "\xef\x9c\x9e",
 	['ICON_FA_DICE_D20'] = "\xef\x9b\x8f",
 	['ICON_FA_LEVEL_DOWN_ALT'] = "\xef\x8e\xbe",
 	['ICON_FA_PAPERCLIP'] = "\xef\x83\x86",
 	['ICON_FA_USER_CLOCK'] = "\xef\x93\xbd",
 	['ICON_FA_SORT_ALPHA_UP'] = "\xef\x85\x9e",
 	['ICON_FA_AUDIO_DESCRIPTION'] = "\xef\x8a\x9e",
 	['ICON_FA_FILE_CSV'] = "\xef\x9b\x9d",
 	['ICON_FA_FILE_DOWNLOAD'] = "\xef\x95\xad",
 	['ICON_FA_SYNC_ALT'] = "\xef\x8b\xb1",
 	['ICON_FA_KISS'] = "\xef\x96\x96",
 	['ICON_FA_HANDS'] = "\xef\x93\x82",
 	['ICON_FA_REPUBLICAN'] = "\xef\x9d\x9e",
 	['ICON_FA_EDIT'] = "\xef\x81\x84",
 	['ICON_FA_UNIVERSITY'] = "\xef\x86\x9c",
 	['ICON_FA_KHANDA'] = "\xef\x99\xad",
 	['ICON_FA_GLASSES'] = "\xef\x94\xb0",
 	['ICON_FA_SQUARE'] = "\xef\x83\x88",
 	['ICON_FA_GRIN_SQUINT'] = "\xef\x96\x85",
 	['ICON_FA_GLOBE'] = "\xef\x82\xac",
 	['ICON_FA_RECEIPT'] = "\xef\x95\x83",
 	['ICON_FA_STRIKETHROUGH'] = "\xef\x83\x8c",
 	['ICON_FA_UNLOCK'] = "\xef\x82\x9c",
 	['ICON_FA_DICE_SIX'] = "\xef\x94\xa6",
 	['ICON_FA_GRIP_VERTICAL'] = "\xef\x96\x8e",
 	['ICON_FA_PILLS'] = "\xef\x92\x84",
 	['ICON_FA_EXCLAMATION'] = "\xef\x84\xaa",
 	['ICON_FA_PERSON_BOOTH'] = "\xef\x9d\x96",
 	['ICON_FA_CALENDAR_PLUS'] = "\xef\x89\xb1",
 	['ICON_FA_SMOG'] = "\xef\x9d\x9f",
 	['ICON_FA_LOCATION_ARROW'] = "\xef\x84\xa4",
 	['ICON_FA_UMBRELLA'] = "\xef\x83\xa9",
 	['ICON_FA_QURAN'] = "\xef\x9a\x87",
 	['ICON_FA_UNDO'] = "\xef\x83\xa2",
 	['ICON_FA_DUMPSTER'] = "\xef\x9e\x93",
 	['ICON_FA_FUNNEL_DOLLAR'] = "\xef\x99\xa2",
 	['ICON_FA_INDENT'] = "\xef\x80\xbc",
 	['ICON_FA_LANGUAGE'] = "\xef\x86\xab",
 	['ICON_FA_ARROW_ALT_CIRCLE_UP'] = "\xef\x8d\x9b",
 	['ICON_FA_ROUTE'] = "\xef\x93\x97",
 	['ICON_FA_USER_ALT'] = "\xef\x90\x86",
 	['ICON_FA_TIMES'] = "\xef\x80\x8d",
 	['ICON_FA_CLINIC_MEDICAL'] = "\xef\x9f\xb2",
 	['ICON_FA_LEVEL_UP_ALT'] = "\xef\x8e\xbf",
 	['ICON_FA_BLIND'] = "\xef\x8a\x9d",
 	['ICON_FA_CHEESE'] = "\xef\x9f\xaf",
 	['ICON_FA_PHONE_SQUARE'] = "\xef\x82\x98",
 	['ICON_FA_SHOPPING_BASKET'] = "\xef\x8a\x91",
 	['ICON_FA_ICE_CREAM'] = "\xef\xa0\x90",
 	['ICON_FA_RING'] = "\xef\x9c\x8b",
 	['ICON_FA_CITY'] = "\xef\x99\x8f",
 	['ICON_FA_TEXT_WIDTH'] = "\xef\x80\xb5",
 	['ICON_FA_RSS_SQUARE'] = "\xef\x85\x83",
 	['ICON_FA_PAINT_BRUSH'] = "\xef\x87\xbc",
 	['ICON_FA_PARACHUTE_BOX'] = "\xef\x93\x8d",
 	['ICON_FA_SIM_CARD'] = "\xef\x9f\x84",
 	['ICON_FA_CLOUD_UPLOAD_ALT'] = "\xef\x8e\x82",
 	['ICON_FA_SORT_UP'] = "\xef\x83\x9e",
 	['ICON_FA_SIGN_OUT_ALT'] = "\xef\x8b\xb5",
 	['ICON_FA_USER_NINJA'] = "\xef\x94\x84",
 	['ICON_FA_SIGN_IN_ALT'] = "\xef\x8b\xb6",
 	['ICON_FA_MUG_HOT'] = "\xef\x9e\xb6",
 	['ICON_FA_SHARE_ALT'] = "\xef\x87\xa0",
 	['ICON_FA_CALENDAR_CHECK'] = "\xef\x89\xb4",
 	['ICON_FA_PEN_FANCY'] = "\xef\x96\xac",
 	['ICON_FA_BIOHAZARD'] = "\xef\x9e\x80",
 	['ICON_FA_BED'] = "\xef\x88\xb6",
 	['ICON_FA_FILE_SIGNATURE'] = "\xef\x95\xb3",
 	['ICON_FA_TOGGLE_OFF'] = "\xef\x88\x84",
 	['ICON_FA_TRAFFIC_LIGHT'] = "\xef\x98\xb7",
 	['ICON_FA_TRACTOR'] = "\xef\x9c\xa2",
 	['ICON_FA_MEH_ROLLING_EYES'] = "\xef\x96\xa5",
 	['ICON_FA_COMMENT_ALT'] = "\xef\x89\xba",
 	['ICON_FA_RULER_HORIZONTAL'] = "\xef\x95\x87",
 	['ICON_FA_PAINT_ROLLER'] = "\xef\x96\xaa",
 	['ICON_FA_HAT_WIZARD'] = "\xef\x9b\xa8",
 	['ICON_FA_CALENDAR'] = "\xef\x84\xb3",
 	['ICON_FA_MICROPHONE'] = "\xef\x84\xb0",
 	['ICON_FA_FOOTBALL_BALL'] = "\xef\x91\x8e",
 	['ICON_FA_ALLERGIES'] = "\xef\x91\xa1",
 	['ICON_FA_ID_CARD'] = "\xef\x8b\x82",
 	['ICON_FA_REDO_ALT'] = "\xef\x8b\xb9",
 	['ICON_FA_PLAY_CIRCLE'] = "\xef\x85\x84",
 	['ICON_FA_THERMOMETER'] = "\xef\x92\x91",
 	['ICON_FA_DOLLAR_SIGN'] = "\xef\x85\x95",
 	['ICON_FA_DUNGEON'] = "\xef\x9b\x99",
 	['ICON_FA_COMPRESS'] = "\xef\x81\xa6",
 	['ICON_FA_SEARCH_LOCATION'] = "\xef\x9a\x89",
 	['ICON_FA_BLENDER_PHONE'] = "\xef\x9a\xb6",
 	['ICON_FA_ANGLE_RIGHT'] = "\xef\x84\x85",
 	['ICON_FA_CHESS_QUEEN'] = "\xef\x91\x85",
 	['ICON_FA_PAGER'] = "\xef\xa0\x95",
 	['ICON_FA_MEH_BLANK'] = "\xef\x96\xa4",
 	['ICON_FA_EJECT'] = "\xef\x81\x92",
 	['ICON_FA_HOURGLASS_END'] = "\xef\x89\x93",
 	['ICON_FA_TOOTH'] = "\xef\x97\x89",
 	['ICON_FA_BUSINESS_TIME'] = "\xef\x99\x8a",
 	['ICON_FA_PLACE_OF_WORSHIP'] = "\xef\x99\xbf",
 	['ICON_FA_MOON'] = "\xef\x86\x86",
 	['ICON_FA_GRIN_TONGUE_SQUINT'] = "\xef\x96\x8a",
 	['ICON_FA_WALKING'] = "\xef\x95\x94",
 	['ICON_FA_SHIPPING_FAST'] = "\xef\x92\x8b",
 	['ICON_FA_CARET_LEFT'] = "\xef\x83\x99",
 	['ICON_FA_DICE'] = "\xef\x94\xa2",
 	['ICON_FA_RUBLE_SIGN'] = "\xef\x85\x98",
 	['ICON_FA_RULER_VERTICAL'] = "\xef\x95\x88",
 	['ICON_FA_HAND_POINTER'] = "\xef\x89\x9a",
 	['ICON_FA_TAPE'] = "\xef\x93\x9b",
 	['ICON_FA_SHOPPING_BAG'] = "\xef\x8a\x90",
 	['ICON_FA_SKIING_NORDIC'] = "\xef\x9f\x8a",
 	['ICON_FA_HIPPO'] = "\xef\x9b\xad",
 	['ICON_FA_CUBE'] = "\xef\x86\xb2",
 	['ICON_FA_CAPSULES'] = "\xef\x91\xab",
 	['ICON_FA_KIWI_BIRD'] = "\xef\x94\xb5",
 	['ICON_FA_CHEVRON_CIRCLE_UP'] = "\xef\x84\xb9",
 	['ICON_FA_MARS_STROKE_V'] = "\xef\x88\xaa",
 	['ICON_FA_POO_STORM'] = "\xef\x9d\x9a",
 	['ICON_FA_JOINT'] = "\xef\x96\x95",
 	['ICON_FA_MARS_STROKE_H'] = "\xef\x88\xab",
 	['ICON_FA_ADDRESS_BOOK'] = "\xef\x8a\xb9",
 	['ICON_FA_PROCEDURES'] = "\xef\x92\x87",
 	['ICON_FA_GEM'] = "\xef\x8e\xa5",
 	['ICON_FA_RULER_COMBINED'] = "\xef\x95\x86",
 	['ICON_FA_BRAIN'] = "\xef\x97\x9c",
 	['ICON_FA_STAR_AND_CRESCENT'] = "\xef\x9a\x99",
 	['ICON_FA_FIGHTER_JET'] = "\xef\x83\xbb",
 	['ICON_FA_SPACE_SHUTTLE'] = "\xef\x86\x97",
 	['ICON_FA_MAP_PIN'] = "\xef\x89\xb6",
 	['ICON_FA_ALIGN_CENTER'] = "\xef\x80\xb7",
 	['ICON_FA_SORT_ALPHA_DOWN'] = "\xef\x85\x9d",
 	['ICON_FA_PARKING'] = "\xef\x95\x80",
 	['ICON_FA_MAP_SIGNS'] = "\xef\x89\xb7",
 	['ICON_FA_PALETTE'] = "\xef\x94\xbf",
 	['ICON_FA_GLASS_MARTINI'] = "\xef\x80\x80",
 	['ICON_FA_TIMES_CIRCLE'] = "\xef\x81\x97",
 	['ICON_FA_MONUMENT'] = "\xef\x96\xa6",
 	['ICON_FA_GUITAR'] = "\xef\x9e\xa6",
 	['ICON_FA_GRIN_BEAM'] = "\xef\x96\x82",
 	['ICON_FA_KEY'] = "\xef\x82\x84",
 	['ICON_FA_TH_LIST'] = "\xef\x80\x8b",
 	['ICON_FA_SHARE_ALT_SQUARE'] = "\xef\x87\xa1",
 	['ICON_FA_DRUM'] = "\xef\x95\xa9",
 	['ICON_FA_FILE_CONTRACT'] = "\xef\x95\xac",
 	['ICON_FA_RESTROOM'] = "\xef\x9e\xbd",
 	['ICON_FA_UNLOCK_ALT'] = "\xef\x84\xbe",
 	['ICON_FA_MICROPHONE_ALT_SLASH'] = "\xef\x94\xb9",
 	['ICON_FA_USER_SECRET'] = "\xef\x88\x9b",
 	['ICON_FA_ARROW_RIGHT'] = "\xef\x81\xa1",
 	['ICON_FA_FILE_VIDEO'] = "\xef\x87\x88",
 	['ICON_FA_ARROW_ALT_CIRCLE_RIGHT'] = "\xef\x8d\x9a",
 	['ICON_FA_COMMENT'] = "\xef\x81\xb5",
 	['ICON_FA_CALENDAR_WEEK'] = "\xef\x9e\x84",
 	['ICON_FA_USER_GRADUATE'] = "\xef\x94\x81",
 	['ICON_FA_HAND_MIDDLE_FINGER'] = "\xef\xa0\x86",
 	['ICON_FA_POO'] = "\xef\x8b\xbe",
 	['ICON_FA_GRIP_LINES_VERTICAL'] = "\xef\x9e\xa5",
 	['ICON_FA_TABLE'] = "\xef\x83\x8e",
 	['ICON_FA_POLL'] = "\xef\x9a\x81",
 	['ICON_FA_CAR_ALT'] = "\xef\x97\x9e",
 	['ICON_FA_THUMBS_UP'] = "\xef\x85\xa4",
 	['ICON_FA_TRADEMARK'] = "\xef\x89\x9c",
 	['ICON_FA_CLOUD_MOON'] = "\xef\x9b\x83",
 	['ICON_FA_VIALS'] = "\xef\x92\x93",
 	['ICON_FA_FIRST_AID'] = "\xef\x91\xb9",
 	['ICON_FA_ERASER'] = "\xef\x84\xad",
 	['ICON_FA_MARS'] = "\xef\x88\xa2",
 	['ICON_FA_STAR_OF_LIFE'] = "\xef\x98\xa1",
 	['ICON_FA_FEATHER'] = "\xef\x94\xad",
 	['ICON_FA_SQUARE_FULL'] = "\xef\x91\x9c",
 	['ICON_FA_DOLLY'] = "\xef\x91\xb2",
 	['ICON_FA_HOURGLASS_START'] = "\xef\x89\x91",
 	['ICON_FA_GRIN_HEARTS'] = "\xef\x96\x84",
 	['ICON_FA_CUBES'] = "\xef\x86\xb3",
 	['ICON_FA_HASHTAG'] = "\xef\x8a\x92",
 	['ICON_FA_SEEDLING'] = "\xef\x93\x98",
 	['ICON_FA_HAYKAL'] = "\xef\x99\xa6",
 	['ICON_FA_TSHIRT'] = "\xef\x95\x93",
 	['ICON_FA_LAUGH_SQUINT'] = "\xef\x96\x9b",
 	['ICON_FA_HDD'] = "\xef\x82\xa0",
 	['ICON_FA_NEWSPAPER'] = "\xef\x87\xaa",
 	['ICON_FA_HOSPITAL_ALT'] = "\xef\x91\xbd",
 	['ICON_FA_USER_SLASH'] = "\xef\x94\x86",
 	['ICON_FA_FILE_WORD'] = "\xef\x87\x82",
 	['ICON_FA_ENVELOPE_SQUARE'] = "\xef\x86\x99",
 	['ICON_FA_GENDERLESS'] = "\xef\x88\xad",
 	['ICON_FA_DICE_FIVE'] = "\xef\x94\xa3",
 	['ICON_FA_SYNAGOGUE'] = "\xef\x9a\x9b",
 	['ICON_FA_PAW'] = "\xef\x86\xb0",
 	['ICON_FA_RADIATION'] = "\xef\x9e\xb9",
 	['ICON_FA_CROSS'] = "\xef\x99\x94",
 	['ICON_FA_ARCHIVE'] = "\xef\x86\x87",
 	['ICON_FA_PHONE_VOLUME'] = "\xef\x8a\xa0",
 	['ICON_FA_SOLAR_PANEL'] = "\xef\x96\xba",
 	['ICON_FA_INFINITY'] = "\xef\x94\xb4",
 	['ICON_FA_HAND_POINT_DOWN'] = "\xef\x82\xa7",
 	['ICON_FA_MAP_MARKER'] = "\xef\x81\x81",
 	['ICON_FA_CALENDAR_ALT'] = "\xef\x81\xb3",
 	['ICON_FA_AMERICAN_SIGN_LANGUAGE_INTERPRETING'] = "\xef\x8a\xa3",
 	['ICON_FA_BINOCULARS'] = "\xef\x87\xa5",
 	['ICON_FA_STICKY_NOTE'] = "\xef\x89\x89",
 	['ICON_FA_RUNNING'] = "\xef\x9c\x8c",
 	['ICON_FA_PEN_NIB'] = "\xef\x96\xad",
 	['ICON_FA_MAP_MARKED'] = "\xef\x96\x9f",
 	['ICON_FA_EXPAND'] = "\xef\x81\xa5",
 	['ICON_FA_TRUCK_PICKUP'] = "\xef\x98\xbc",
 	['ICON_FA_HOLLY_BERRY'] = "\xef\x9e\xaa",
 	['ICON_FA_PRESCRIPTION_BOTTLE'] = "\xef\x92\x85",
 	['ICON_FA_LAPTOP_CODE'] = "\xef\x97\xbc",
 	['ICON_FA_GOLF_BALL'] = "\xef\x91\x90",
 	['ICON_FA_SKULL_CROSSBONES'] = "\xef\x9c\x94",
 	['ICON_FA_TAXI'] = "\xef\x86\xba",
 	['ICON_FA_ROCKET'] = "\xef\x84\xb5",
 	['ICON_FA_YIN_YANG'] = "\xef\x9a\xad",
 	['ICON_FA_FINGERPRINT'] = "\xef\x95\xb7",
 	['ICON_FA_ARROWS_ALT'] = "\xef\x82\xb2",
 	['ICON_FA_UNDERLINE'] = "\xef\x83\x8d",
 	['ICON_FA_ARROW_CIRCLE_UP'] = "\xef\x82\xaa",
 	['ICON_FA_BASKETBALL_BALL'] = "\xef\x90\xb4",
 	['ICON_FA_DESKTOP'] = "\xef\x84\x88",
 	['ICON_FA_SPINNER'] = "\xef\x84\x90",
 	['ICON_FA_TOGGLE_ON'] = "\xef\x88\x85",
 	['ICON_FA_STOPWATCH'] = "\xef\x8b\xb2",
 	['ICON_FA_ARROW_ALT_CIRCLE_LEFT'] = "\xef\x8d\x99",
 	['ICON_FA_GAS_PUMP'] = "\xef\x94\xaf",
 	['ICON_FA_EXTERNAL_LINK_ALT'] = "\xef\x8d\x9d",
 	['ICON_FA_FROWN'] = "\xef\x84\x99",
 	['ICON_FA_RULER'] = "\xef\x95\x85",
 	['ICON_FA_FLAG_USA'] = "\xef\x9d\x8d",
 	['ICON_FA_GRIN'] = "\xef\x96\x80",
 	['ICON_FA_THEATER_MASKS'] = "\xef\x98\xb0",
 	['ICON_FA_ARROW_CIRCLE_LEFT'] = "\xef\x82\xa8",
 	['ICON_FA_HIGHLIGHTER'] = "\xef\x96\x91",
 	['ICON_FA_POLL_H'] = "\xef\x9a\x82",
 	['ICON_FA_SERVER'] = "\xef\x88\xb3",
 	['ICON_FA_TRASH_RESTORE'] = "\xef\xa0\xa9",
 	['ICON_FA_SPRAY_CAN'] = "\xef\x96\xbd",
 	['ICON_FA_BOWLING_BALL'] = "\xef\x90\xb6",
 	['ICON_FA_LAUGH'] = "\xef\x96\x99",
 	['ICON_FA_TERMINAL'] = "\xef\x84\xa0",
 	['ICON_FA_WINDOW_MINIMIZE'] = "\xef\x8b\x91",
 	['ICON_FA_HOME'] = "\xef\x80\x95",
 	['ICON_FA_UTENSIL_SPOON'] = "\xef\x8b\xa5",
 	['ICON_FA_QUIDDITCH'] = "\xef\x91\x98",
 	['ICON_FA_APPLE_ALT'] = "\xef\x97\x91",
 	['ICON_FA_UMBRELLA_BEACH'] = "\xef\x97\x8a",
 	['ICON_FA_CANNABIS'] = "\xef\x95\x9f",
 	['ICON_FA_LAUGH_BEAM'] = "\xef\x96\x9a",
 	['ICON_FA_TEETH_OPEN'] = "\xef\x98\xaf",
 	['ICON_FA_DRUMSTICK_BITE'] = "\xef\x9b\x97",
 	['ICON_FA_CHART_PIE'] = "\xef\x88\x80",
 	['ICON_FA_SD_CARD'] = "\xef\x9f\x82",
 	['ICON_FA_HANDS_HELPING'] = "\xef\x93\x84",
 	['ICON_FA_PASTE'] = "\xef\x83\xaa",
 	['ICON_FA_OM'] = "\xef\x99\xb9",
 	['ICON_FA_LUGGAGE_CART'] = "\xef\x96\x9d",
 	['ICON_FA_INDUSTRY'] = "\xef\x89\xb5",
 	['ICON_FA_SWIMMER'] = "\xef\x97\x84",
 	['ICON_FA_RADIATION_ALT'] = "\xef\x9e\xba",
 	['ICON_FA_COMPRESS_ARROWS_ALT'] = "\xef\x9e\x8c",
 	['ICON_FA_ROAD'] = "\xef\x80\x98",
 	['ICON_FA_IMAGE'] = "\xef\x80\xbe",
 	['ICON_FA_CHILD'] = "\xef\x86\xae",
 	['ICON_FA_ANGLE_DOUBLE_RIGHT'] = "\xef\x84\x81",
 	['ICON_FA_CLOUD_MOON_RAIN'] = "\xef\x9c\xbc",
 	['ICON_FA_DOOR_OPEN'] = "\xef\x94\xab",
 	['ICON_FA_GRIN_TONGUE_WINK'] = "\xef\x96\x8b",
 	['ICON_FA_REPLY_ALL'] = "\xef\x84\xa2",
 	['ICON_FA_TEMPERATURE_LOW'] = "\xef\x9d\xab",
 	['ICON_FA_INBOX'] = "\xef\x80\x9c",
 	['ICON_FA_FEMALE'] = "\xef\x86\x82",
 	['ICON_FA_SYRINGE'] = "\xef\x92\x8e",
 	['ICON_FA_CIRCLE_NOTCH'] = "\xef\x87\x8e",
 	['ICON_FA_WEIGHT'] = "\xef\x92\x96",
 	['ICON_FA_SNOWPLOW'] = "\xef\x9f\x92",
 	['ICON_FA_TABLE_TENNIS'] = "\xef\x91\x9d",
 	['ICON_FA_LOW_VISION'] = "\xef\x8a\xa8",
 	['ICON_FA_FILE_IMPORT'] = "\xef\x95\xaf",
 	['ICON_FA_ITALIC'] = "\xef\x80\xb3",
 	['ICON_FA_CLOSED_CAPTIONING'] = "\xef\x88\x8a",
 	['ICON_FA_CHALKBOARD'] = "\xef\x94\x9b",
 	['ICON_FA_BUILDING'] = "\xef\x86\xad",
 	['ICON_FA_TACHOMETER_ALT'] = "\xef\x8f\xbd",
 	['ICON_FA_BUS'] = "\xef\x88\x87",
 	['ICON_FA_ANGLE_DOWN'] = "\xef\x84\x87",
 	['ICON_FA_HAND_ROCK'] = "\xef\x89\x95",
 	['ICON_FA_FORWARD'] = "\xef\x81\x8e",
 	['ICON_FA_HELICOPTER'] = "\xef\x94\xb3",
 	['ICON_FA_PODCAST'] = "\xef\x8b\x8e",
 	['ICON_FA_TRUCK_MOVING'] = "\xef\x93\x9f",
 	['ICON_FA_BUG'] = "\xef\x86\x88",
 	['ICON_FA_SHIELD_ALT'] = "\xef\x8f\xad",
 	['ICON_FA_FILL_DRIP'] = "\xef\x95\xb6",
 	['ICON_FA_COMMENT_SLASH'] = "\xef\x92\xb3",
 	['ICON_FA_SUITCASE'] = "\xef\x83\xb2",
 	['ICON_FA_SKATING'] = "\xef\x9f\x85",
 	['ICON_FA_TOILET'] = "\xef\x9f\x98",
 	['ICON_FA_ENVELOPE_OPEN_TEXT'] = "\xef\x99\x98",
 	['ICON_FA_HAND_HOLDING'] = "\xef\x92\xbd",
 	['ICON_FA_VENUS_MARS'] = "\xef\x88\xa8",
 	['ICON_FA_HEART_BROKEN'] = "\xef\x9e\xa9",
 	['ICON_FA_UTENSILS'] = "\xef\x8b\xa7",
 	['ICON_FA_TH_LARGE'] = "\xef\x80\x89",
 	['ICON_FA_AT'] = "\xef\x87\xba",
 	['ICON_FA_FILE'] = "\xef\x85\x9b",
 	['ICON_FA_TENGE'] = "\xef\x9f\x97",
 	['ICON_FA_FLAG_CHECKERED'] = "\xef\x84\x9e",
 	['ICON_FA_FILM'] = "\xef\x80\x88",
 	['ICON_FA_FILL'] = "\xef\x95\xb5",
 	['ICON_FA_GRIN_SQUINT_TEARS'] = "\xef\x96\x86",
 	['ICON_FA_PERCENT'] = "\xef\x8a\x95",
 	['ICON_FA_BOOK'] = "\xef\x80\xad",
 	['ICON_FA_METEOR'] = "\xef\x9d\x93",
 	['ICON_FA_TRASH'] = "\xef\x87\xb8",
 	['ICON_FA_FILE_AUDIO'] = "\xef\x87\x87",
 	['ICON_FA_SATELLITE_DISH'] = "\xef\x9f\x80",
 	['ICON_FA_POOP'] = "\xef\x98\x99",
 	['ICON_FA_STAR'] = "\xef\x80\x85",
 	['ICON_FA_GIFTS'] = "\xef\x9e\x9c",
 	['ICON_FA_GHOST'] = "\xef\x9b\xa2",
 	['ICON_FA_PRESCRIPTION_BOTTLE_ALT'] = "\xef\x92\x86",
 	['ICON_FA_MONEY_BILL_WAVE_ALT'] = "\xef\x94\xbb",
 	['ICON_FA_NEUTER'] = "\xef\x88\xac",
 	['ICON_FA_BAND_AID'] = "\xef\x91\xa2",
 	['ICON_FA_WIFI'] = "\xef\x87\xab",
 	['ICON_FA_MASK'] = "\xef\x9b\xba",
 	['ICON_FA_VENUS_DOUBLE'] = "\xef\x88\xa6",
 	['ICON_FA_CHEVRON_UP'] = "\xef\x81\xb7",
 	['ICON_FA_HAND_SPOCK'] = "\xef\x89\x99",
 	['ICON_FA_HAND_POINT_UP'] = "\xea\x9b\xb0"
}

setmetatable(fa, {
	__call = function(t, v)
		if (type(v) == 'string') then
			return t['ICON_'..v:upper()] or '?'
		end
		return '?'
	end
})

fa_base = "7])#######aIaUI'/###[),##0rC$#Q6>##T@;*>6v0P5t[ZD*?@'o/fY;99A<H$$m*m<-s?^01iZn42r^>h>Q.>>#CEnB4aNV=B-<+F-NhFJ(*;jl&6b(*Hlme+MSm[D*1c5&5#-0%J$n0i@0g@J1H/<P]U-d<BsbU^>Rq.>-Q@pV-TT$=(>O($%;U^C-FqEn/<_[FHOES($LduH2@Wfi'N3JuB?@DJSm3SY,ZqEn/]J[^I6A#F#84S>-8Mfn0+>00F(1>/.wxu=l/ul[$L$S+HZ?`'TSQRrmF+=G2I/FC2())m&l(wM,odPir0P5##OV8,j@nU=Nw$>5vr#um#`??&M]em##]obkLYX-##:Zh3v;7YY#iOc)MenY8N]Q7fM/[AVm5Rq#$[aP+#OCDX-/Mi63-CkV74iWh#Jj/]tZ4ZV$*9nJ;sM$=(h^QcMEY0=#l?*1#6Y0Z$PSltQZr)oCM-m.L/047I(*Sj1E.nx=BbcA#x[k&#ZWc%XF4'?-&25##u<X]Yk2*#vOxe+M5L@6/eXj)#&sPXN=x>W-vodx',v%/L=x5##vLXS7@6EW%c$V=u2]#x'/dU_&F####o^^C-rp9)MUv-tL/sG&PNll-M+xSfLgXEY.bHgf(G&l?-v4T;-(g6'Q/dY1N7CYcMh;?>#jMxV%jIhk4dvGl=OtG&#M(K&#r-@da%_A`a[si9D:Qt-$H)###:rT;-HpNCON;#gL46n]OwLDiLE^e*N8PZY#d,PY#H09kO&0>F%lG.+M/(#GMr=6##K%pxusWWjMl<]0#%)&Fe_bO_/tNJ2L3Ip-6A^4m'sJU_8G,>##)*-xKt*dGMSLT_-gtx&$Q97I-9wvuPp`Z.q;Txp7kMF&#jZqw0tr[fLe[@`aNN/.v/#@`&U#SRN+T0<-=hPhL=SN>.lV(?#wUb&#(HqhL><+;.rY12'*P,:VCKs9)*^FW/WFblA%?eA#B3f;--%9gLjsJfL%%HtM3jBK-:M#<-9t/OMI7$##nWs-$)2(F.vU'^#)MgGM'07#%[q6W%jjE_/P-<p^05J'.ZRtGM&<x,vXRwA-;UfZ$S@+?.)V>W-YX<wT06b2(av-K<=5v5M6t&/L'n]j-p0N2rQ0gw'iiAdO(L>gLIHqI8uhF&#FSk9VW$s;-5@P)N?b>;-@]Ewp/R,,)n4t;MGxS,Mi[@`aSW&.$H,>uu2F(&O1OJJ.)PUV$4?7^#,.m<-Y;5]))t3Q801O2(gxpP8BXO&#^a*s7c^'^#[@:dMcqs.LPGa-Z2d_-QwaQd+g1k?%2)[w'g$_-6EYZ2r3gDE-7t.>-WEnR8Oc4?.O8F0&gXk9`jPF;-IW1RWq`hQanDdpKg]<Z%34cA#Sjf;-S1NU/$2YY#D,>>#L-ZF%Un7ppVKDiLmM+kLRV.R&7<l>[eoaZ%JZeGMr5kf-S:ek=BsL_]vTJX-3s3kO+WW&mY57#%gTs;-wPvD-xh/k$a^eHMBm^g-#'LKEDqQm8SR&:)>liEIed-Audr+_J(hJ2LLF/.?w`%/Lw(>##e^f8.`_Y@t'sOk4CC_,M&g@Q-XHO,%)c'^#AC1:2Q,^:)aZcQj;](##bX^&#.&Uw0i/968-I1_AM+gxu:D1_AWWd9MwIO&#;h:ENcg$R8$lF&#l,kp729@k=2V/&vt:T;-64^gLhFblA:Xep0#?x,vN@ek=H)###Fm(P-kU)>M_hI'Mlr2+9$.53D7+lo7qALk++V>x'%fJ_/mXuQs%]p%O?8CP8(qS:)w2-Wo/hDB%Ddx58,0nw'l8N_&5BK/6x:HW-ShNW8OC?>#7Rp@O)tg`M0*u48>1I2L:+MFR.5s9)al,Q8*772L=+L,M7e0&v#&v5&K,j&#JYWZO&w7^.?BbxuN,.>%m3A=-w3ukL&`YdMrPoV%,B+3;(b0_-0<?xKiYLO9m,V?%SCZY#G^*-M=$'$.g+'p7c<m:VAEUx9?^oX#HHj>Re,-e%%76gLDcdi9=(1^#-;8F-vF5s-pKWk8*>=KN%<x,vpBm]%#/=R*uZE_Ai,FaN?/P)'7EtM9s@.kX2+@68R7>3D$(^fLa+p+MIAT;-O)oJM97GcMqJ6##fxaS7G09kOk&nxu.#P[&-vMcsrw2<-fV2F&wCh&v#(^fLJ<T;-(=8K'`isR<51(^#KuGp7`8T9VDv4uu$iVk+]trq7L)72Lu7AK*1X1I&'Z-`&r#K9rY=e_S[VT=ucL,X&+H0<-S%[=.1rbCs/Wi-Hg3Y>-K+I2LfX=R*cNx4pKDX-?OdmdFd;EnN?94P:Eq=_Jx)s%l4-i&#(q,tLHpLtLFn;J:ic^d421p0%bb%3Mxc^98nw'#vTtj89Sjb&#K%')N:W8o'%rd29gA,'$1TvD-,?jB%*QhofZUJF.swM9ri%h58fhF?IK%qXu;vEgLGX@`aW#)W7rIF-ZVR#.6NKAbNwS)qL/,YS7mgSs-uT<$O2Dx,vMoIfLK8QwLGBh<.:nV:vos:DtUG+kLMUqm8CL@K<W7+n-Y$#F@3V5@I4(m<-nXZL-B?$q&a_%3M#1#,M89go%YT8R*8GBR3T98'dxJpS%Be`-QC._GM^;S>-:Ml`%jD4;-xcS=uuuVqKO:Zu#L%pxuq&%(;#,Uw0M4p&#IM%/LHCMwpr/=KjW3<k9xma-Z>:v?.dt*_M=aO8&(a/R3<$@(stTE3M(`#tM[D6L-(+*n%M*a58>sl2rEh`=-h>ts7i?2F7MrbKs<&gD8`LTpT>$NJ:$g^d4SsF?-hRiqN&epx:hb$l+)nbp'aNA[#CIIs-J-`B8C<Pn*#]B#$2is-$c+?>#(ok&#RQ&v#Fle&,7N3T[El)Ng#+###p>J@qb<1/q&<[0q3a<1q?)k1q2eo5qYD@8q'cB:qW$<<qkZ8=q$6,>q3al>qEAi?qgRXAqPdsDqpiPFq*V`GqO'(fqv)IKq4)tLqGMTMqgR2Oqw3/Pq4q4QqCEuQqYDISqv7bTqiaJXq0ZlYq8s:ZqSFO]qle'^q7?E`qYD#bqliYbq0i.dqS3C+rga$gq,sjhqTF)kq#:AlqKdUnq(ogqqPn;sqx5>uq1g1vqBG.wqV.4xq$@$$r-XH$rEj8&rdic'r,Vr(r7%S)rH[O*rX?_Frr5n,rQ4m/rIi<5rt1k5rETJ9rqpv?r=?W@rMpJArf%2Cr'V%DrI*:Fr`Q-cr#ZWHrS(dJrx?]Lr.e=Mr8-lMr@E:NrJjqNrV2IOrdc<Pru7'Qr+cgQrBU)SrP*jSreafTrvAcUr0#`VrC`eWro3$Zr1w2[r?Ej[rZJG^rt=`_rQ>3dr>fwsrYL'urvEHvr0'EwrK&pxr[PY#sm+M$swI%%s+iR%s8==&sR^QCs%s8*s=S5+sQ.),s#_F.s9EL/sGj-0sUDw0sciW1ssIT2s/%H3s?O24sJ$s4sVBJ5scg+6suM17sCf*9sZXB:si'$;s/'N<s;E&=sPJY>sbc(?sj%M?suO7@s1++As=UkAsTN6CsfvmCs-sAEs?S>FsS@MGsl9oHs;K_JsHvHKs_iaLspCTMs1C)OsG*/Psh)YQsvSCRs4G[SsFxNTsVF0Usf'-Vs#k;Ws6?&XsA^SXsN8GYs^](ZslC.[s<['^sK*_^sVH6_snVs`s25pas=YPbsW']ds-KhfsVJ<hsdu&is;hiksbsOmsuYUns>f<psNPuusE8a@t^iH,tK<]1tD*>>#ZtX.qfHC/q*Hn0q8sW1qD;02q9'>6q_V[8q+oT:qZf-C8u#Qm81al>qB;`?qYFFAqA^jDqhiPFq%>;GqEXFeqj#@Kq/gNLqEABMq[L)OqrwiOq/XfPqB?lQqOdLRqno3TqeN/XqQtv.%W.PZqdRb]qs-U^q@Wj`qfP5bqpulbq>O4eqW9:fqms?gq:)'iq^k`kq,e+mqRvqnq<7?rqd),uq'HYuq9/`vqGS@wqaDJH8fCV)bL870g3C%EYBKq)rNnk*rbQh+r2Mg.rk9J1rnsv.%c8V?Xm@$EY:d9Lru]6;8&hcY@#t#LB1s7bDGR)UHWdtKKil2bM&1(XP4<sNSs99T%diC'a=nW<cYrE-hnErZk@hlZtc^%RRSCN$XnA<k]+PP*`A6^9dX]R0g5iq;-MC8G&,O&EY#WB-s$pH;8V5ua=rEt3A-N2ICp?wDYt3:5sbg+6spAu6s@Se8satv.%;&$EYOrmI8B_7+k0j^6n<]V0pRH)[tdD]9v,Cjh'q>tDYn;'HsrrH;8q0AZ5wUpMs=O;OsWa+Qsm5lQs&mhRs=SnSsO4kTsZRBUsk3?Vs-'WWs;K8XsEjfXsTDYYsbi:ZsppKM8U.YEt'.WL'6$5+)Bm-%+1)uDY)L6msqG:ns>f<ps/C8G&2&3/tU)h+vFNG/(F?5/(A0#/(=w].(7eA.(.Fj-('4N-(x'<-(o_d,(f@6,([(h+(S`9+(MS'+(=TR)(*6%)(#*i((nT(((c<Y'(_0G'(P[]&(LOJ&(HC8&(C1s%(>%a%(6c;%(2V)%(iQww'Bq$w'7ehv'2RLv'kRxt'd4Jt'T``s'>#Zr':mGr'*$0q'tmsp'mTNp'Sb6o'I7Ln'<cbm'.D4m'b,;k'JnJi'7_/i'-:Nh'$(3h'i(_f'WlBf'QSte'E5Fe',*`c'vmCc'mNlb'd6Gb'Vb]a'<>Q_'a^*]'iF]X'c4AX'X]OQ'ZplN'PK5N'Ct82').3L'n@$K'LAOI'BmeH'o$#F'MuDD';c)D'5PdC'0DQC',8?C'#pgB's]KB'f2bA'`&OA'Wd*A'QQe@'I37@'C'%@';eU?'7XC?'r48='US;<'LAv;'Aa#;'/<B:''$t9'C]F6'5P46'0>o5'+2]5''&J5'#p75'rP`4'i>D4'e224'^pc3'RHpm&1431'i:h/'WSb.'DZ@-')$D,'rTc+'j<>+'_tf*'YbJ*'L7a)'E%E)'@o2)'6PZ('2DH(',2-('q2X&'_j*&'OEI%'@X:$'0:c#'*(G#'i:8x&e.&x&axiw&VS2w&NAmv&E#?v&4HKu&%U3t&j0Rs&][hr&K+uq&3&Ap&xcro&k2)o&Y^>n&O?gm&9Ual&%Y6k&nFqj&h.Lj&WYbi&J/xh&E#fh&?gIh&06Vg&)$;g&%n(g&sTYf&oHGf&]O&e&G%<d&?cmc&9PQc&vP'b&nDka&h2Oa&BeC_&mx`[&]`;[&FNKY&p*@W&`hqV&Q+lU&kha5&#A_N&sB5J&3G8A&c5l.#4.`$#EUwI.5f($#sIkA#)_6B(I8YY#0%,DN6&l4S0,u4Sap$)**WP#$D]-83E<1R3M7)##mAk-$)rm-$i[)##9`###5Q&##7S###[i'##)]lS.Te68%o(.m/nnQS%Gvmo%>(.m/t*35&H3NP&TvhP/f<jl&xD/2'TPP6'3NJM'-Vfi'RYlS.0b+/(%ZlS.VjFJ(wYlS.qrbf(/VjfLDhTnJ*'+1:c/Fk4'$G&#6w+_JE0e;#+c:kFgCm##=SUw0t9/%#:2>_/O_9*#(.t9)tsY6#Q=,.#AZCwK,/A8#qPk-$Si63#-=t9)(^M7#OU$lLE^_sLGreQ-`Kx>-`WkV.QG###]3S>-GaDE-K3u,/Ak%##T?o-$$h*##_Yl-$TmvV.Z>js.urgo.DQP8.x'-5/(K[8/op8gL2`XjL-qwJr#WajL[ikjL$I=?Q$^jjL*0;'>%dsjL#LP',ii*'cgR.eEihPEn(H#kk)?66#:ZO9`F@59#dr:-m'kB5#6[x(#?tt9)Sg]0#Ue$##>a2hL[P)7#_$o92V)9#MJ(q=#[XVw0V[_E[x/-_JNX59#'#V9V4r5kO0MtQNno)kb^%.F%M?E/#g<o929+6kOsSf;#Ot73#)jbmL<=[3#dncjLY1RA-hvR#/Z](##q5l-$at)##R?&n.R:%##mtfN-I^Y%0uE&##>O*##'m+G-;:7I-=Wvp/is+##>E'##`U^C-YKo/0jk%##hg+##QJwA-1;C`.$<###:`CH-ZqdT-+T]F-i7X?1,P)##eN+##B9'##J_Nb.C7*##p2>o.*:&##Rp-A-.<8F-BZ@Q-`j5d.C+*##+$jE-4T]F-5Y`=-EeF?-w<D].`x$##PMXR--+Yg.`v'##4M.U.e,(##5A;=-](LS-*kw:0/.&##$`%##-hk-$BOA5BR*B5BS3^PB*k'mB36C2CUUo2CIb4JC:WjfLg/AqLLN0woc(IqLK)DF$d.RqL.=SqLh_/.,e4[qL1A]qLL3PF-f:eqL/C=_ng@nqLOMoqLDSxqLkX+rLDN6l3iL*rLfa4rL;_4rLXe=rLa0rR`meNrL;wXrLM#YrLe'crLuD=SVpwjrLw3urL14urLX4G;Lr-'sLD?1sL<o3T)t99sLkMo;:a1]m*%_(R<akh--kpN=#LRE5#:(9R*o=w4#,iAgL]DtJ-Bo,D-C%v[.wG$##.Mdl./u*##b#u_.,i*##[A;=-.3RA-BV^C-sseQ-7_BK-%UHt.Ot+##-Nm-$M7)##JMn-$bK#HNaHB`Ng(.m/0R^%O[Y#AOHD*j0xd>]OrlYxOVuu=P?f8^P$1VuP%PP8.O<r:Qb$_YQNF#vQ1E%vQ7]=;RC7c;RWa3SROV]VRQburRJ[LsR5sj4S-PP8.:&0PSnrooS:0woSba[5Ts6g1T1'slTbva2URZ(JUWVjfL8-?wLE,?wLjBX3PF+PwL,DDeR*(2@C-QW-?GC4R3tw$_]II4R3n9^-?<%u^fNl9kOG+s92K-G5#gg>*#Mr3kX^6+_SCH2+#tZS4#3%:kOA&,F.bG=_8%$vE@0$w:#Ov<0#*h6wgk3H9rZ?Lk4?ERk+;w:R*d].7#E;&F7$A4kXucL&#2/IwK0r3(#[F4kXf#e-6tNH9rHoE-d?k#:)-uK-ZGX@kF;AOwBC)k;#uY7hL=3S>-(MWU-#3^Z.%<%##/ron.^8*##;[lS.>%###Qs.>-(2s2/E9)##3Dk-$RD:>dmBSYdi=rudlJ1;eZn3;eX''We4dBoeWVjfLM_Qj%u@H&MRSR&MBDL[-&-eE[=ur&#=JSk+EMc0#AjX-H.A'F7aYo0,KAwE@hj04#8a$:)nnD_/%+q,#)tL-Z#cXtL:s3<#Xeb9Mt88wgQSwE@1ca6#a5+lL*tL:##;p/#IoSk+2+A-mfE*REu#w^f=,-_SqFl--R9M-ZmsAkFW8/:#F5%:)cbPwBtOl--]$4F%t,c3#C`>w^uMY-Hj>%:)r,BkF,&%5#hAu924NO##xxkERKoDwT1'^w0l,dw'l,dw'anr-$??<kOp8dw'x^J2#<=?0#Q9QwBo6W1#TGdw'AqL,#S@kgLa]BK-Q`Y%0U,+##6w)##dRZL-+j?*0Tv*##_:(##cF)e.:o###o;.:0ofF>#iN@>#%qn-$EpF>#oZ@>#6Al-$wfB>#0In20+4D>#I5B>#%Zk-$F(D>#65l-$RLD>#/sk-$I&G>#vXC>#5)l-$Aen-$8WF>#G<oY-)q/F%,&q-$GdS5']SpP'elpP'7F@Q'^^oi'VJ>m'Zp8gL6'2hL[etaac$:hL>.;hL]3DhL`4DhLE9MhLTqNnS$E;no;f3=?F2Lk+:BO1#h(F-Z#Zr7#hPGoLR.SN1#7@>#6rC>#Qi>>#$tj-$^do-$jt&a+Ls(a+^VD&,?V[A,[nOB,T:]Y,hAxu,-?)?-bSXV-C,<v-mn9w-(i98.`pTS.bPP8..%qo.W7#9/j6QP/jgmS/Je1p/mx8p/Flt50fF220Hr0m08MTm0wd./1alO21%-]N1elIJ1Tvef13D,j1b)F/2mRhJ2Sa&g2?+D,3u&bG3v(_G3v/'d3i_)d3dsOE4kg>A4wqY]4;>$a4bmb&5&%vx4(h]A5pYh^5g5VY5,Aru51=S>6,6uY6+74v6-?:v6.A7v6-R'<7VnNS7xVjfLOUNmLvZ2Z[J`#*5/vRp]d>eg<A_imLs[dB$BermLW_gB-Dq.nLGnlgjl#B*Y$INtAu7Ads`Wgt8Pxgh3<I@&cLQFOMOMWJiKEonL<NpnLjT#oL:C*7qMQ+oLBb5oL=c5oL3h>oLDnGoL[N#PVT.CP2]ui+PJ#e].kxuE7i1W9VTx$kk)G4_A;8Ok+l?j9;eO:_8?RB-dX37kO`fa-6n@%&#6Tp92/E[9##Pa*#e*R1#[=ujt';:0#hK/F%m-P7#S<Rw9J(h--p8S.#$3&REGR+kb]lD5#>h^9MAqE2#B1dQj)3i8#vKLwB@T_w'R'*=#L*=-mfG2R3Mj=kFF$e9D)'D8#W&m^ohCdQjn_86#'m1qLGreQ-EufN-0LWU-nmmt.&,@>#>[k-$4?F>#POA>#L5`T.6P@>#KufN-$.OJ-geF?-xp-A-JbDE-2-Zd.5BC>#n.[a.M->>#Yh?*0J'G>#TAD>#?^Me.IsC>#mZ@Q-:2^Z.dfD>#lGuG-Ts:T.EXF>#wxhH-Vu')0lj>>#1hB>#/g'S-Yn7^.:(F>#]bDE-D&kB-V6T;-8)LS-I@&n.&-?>#_N#<-au')00E?>#SZC>#N96L-rY`=-qaO_.c)D>#Vgi*/f+A>#n*l-$W8=5TvZIQTTE5MT7PPiT77mlTl072Uo=LMU9PliUmC-/V?oLJV4XnJV51IcV6rmGW-A*DWKUecWSnecWFS6dWc_&AX+[]`XNx)&YvF@AY(x3BYJ->YYH5YuY./@>ZWm1?ZfH:VZ`PUrZjH>;[TcRV[$.pr[Y)78]'BMS]p>np]2:j1^'C/M^tVjfLRnx#MNu+$M4$5$M'g*tac&F$M>7P$M9;Y$M%Bc$MVAc$MiB5CLhDt$M)gI[`iJ'%M1Z1%M^rU[ikV9%M#Bqtsl]B%MnJ*ujmcK%MuQcOmS(<]Doo^%MKx_%Mjusu3pug%MG0r%M@6%&MM5%&M4,'vN_#Gv*E*:kFUp;R*P>U9`1%Vw9,Ip^oj0w=#;7/kbBY:-vI@3F%gd04#-jDgLUo-A-D/;x.n5E>#cOl-$('F>#>K,[.%R?>#j5S>-<'kB-qaCH-Gf&V-l5S>-*aNb.>9@>#dPYO-X^AN-[xR#/EE@>#V]k-$nKE>#2rDq/fDA>#wuA>#X-NM-vH6x/6ZE>#H7C>#j*m<-(Nx>-gt:T.UYF>#DIau.vZD>#G^j-$n?E>#[Q@>#0DrP-Aeg0/4,B>#nik-$$eE>#?DB>#wvfN-+V]F-i&v[.dOC>#/hRU.SsE>#+>8F-95N;6]4_Y#v&]Y#NXZY#gI_Y#f?[Y#sd[Y#9b`Y#JG.f2QLZY##mbY#UTaY#j3[Y#<5l-$:c_Y#c:/70cmaY#i%_Y#qsj-$AabY#j#bY#s;bY#-<[61o'[Y#'TbY#)V_Y#0$v[.QrYY#G@;=-]#Us.A=`Y#Yfl-$RU`Y#hSHt.<%`Y#4Bk-$Yhb#-eQF;-ZlwY-LF9v-q^:v-3XY;.)WeW.Yu^S.A3?5/U6;T/KEvl/-wv50^M;20UIL21sJJ21>xYN19&of1K.4,2C&K/2pi9K2uAkc2.WjfLhJhkLl4)rAo%]ea1P#lL_06Y%CFYXn&;v@-4c>lL%:9YI+b.Ye91;MM8%dlL(<32Mu;]0#Qg6R*>5[6#pj0R3DS*7#Ls8w^t5s:#Y8;*#2J$&#Z'%REY_i9;8+M=#-w-.#uQ2kLv/QD-a7po3n']Y#HbaY#cV_Y#'L]Y#'J`Y#ln,D-tCsM-$gG<-tVU10MYZY#TnaY#v5T;-PR[I-6Y`=-fqdT-HeF?-375O-375O-xn,D-9OYO-fX?T-]&wX.vabY#IGuG-cJ8r/k4[Y#m<bY#%qon.DgYY#b2jq/T?^Y#Ee]Y#.,NM-+vre.S3^Y#(QZL-gp-A-j(LS-VZ@Q-Yq9W.;2`Y#76T;-YLx>-wJwA-@]AN-jYKk.WsYY#aeF?-@IvD-LZjfLPJ*a.t3'sLsA1sLt@1sLmHf;:M'3H$,IE-ZA`[-?Q@R9`O'MwBKS#_]kdA_/=TD8#rtl/#3.ggL?R*4#2h5_A[wjQaemC-dV<MwB1q,7#6#H_&kp*=#PM[EeT0/1#S[nEIltPk+1X96#:m0F%hEkQarHi--([GwK^4$_]ddMwB(HB_/';t^f7^n,#FfdpLxN(:#K%aw'.)u=#&(iER8bk5#M+aw'TWK&#%cP-Qull2#&fP-Qn<v:#0Yn^o,uV-H)A;3#_9:R*r%I_&8t0_JgbEk=.c?kFHF4R35:W-HtduE@bs'&#w21_JEcZw00Hj;#(aHwKpOk8#Op<0#xn]EeepX%#6k4R3(-vE@-Z3N?uSs[tAW4s$Q7FD*+i?8%_]B.*#mqB#:;gF4gr*V/)%x[-dsR(sZZ1F*;N;E*SiuE(_i(G`(ok(N89uL([r/F*J33O0%4n0#J&###;w;##@D8@-Zg>A4R#QA#dZ'u$xh$lLHLB(4&P%`&'$fF47`Gn$H9Bq%rbm(5lb%wu+.DT.NP_(a>^pO0XPcr.Ru7?$C?F&NWt`V$Bl>##+#jE-R#S33^?O&#swbI)[(Ls-b3NZ6&TN/M-$xh%b0D.3tVSF4PDRv$9DhR%bV.H)#wY#5bWuAJ10l3(D1LCEp,97;7[rX-7+l3+60c01^Fm8JV97>%G,2i1.e&##xuF:v`FY>#])ChLpDPA#RF`v52,h.*dMYx6#UvA2v6hI&4S=(1BqNHEB097/9FO$0HcQJ&H:5qJI$FQ/&G&t%3Xfi'guqc2SCb`*FbwD4O.#,M%ECK*pY?C#@T/<7Rg;E4hG(v#It_p79(dN'uMP;-L`IX(u,K+E9>_tQL@bh(;v?5/>x];)w?ts8@]UtQlE_^#g3n0#J)###h^YfLQ*88%>u###WEC]41-A.*[*'u$ZVd8/wHeF4Rp;+3JO?IML5Wa4L@/[uC*3G<0/wJ;#1G$pB5$f4D[r%,=d)J<q@JfL'nCdMY*CB#(@$(#P%T*#+b.-#[G_/#6.92#mp@.*dZ'u$d<7f39OnA,(DQF%^]d8/ZGc3FYFuw5?3lD#YRlDNk<`eMg7H<-,Zh&Q^[<7Snbw^M'Qfn0%FXN'O3^m&mc?%b':vV%/rkA#o=2=-dudYPZ&6/(7AbaND,8fPQ09k0hTb6&@JVN'dD[H)0*4Q'^56.Ouj1oeSHAb.?-Bf$%$0w&P?am]Y<(&P]me(#'/###[,=##)9li'r)#,2c6%##=g8gW<#DP-fVIm-n_O]'^Pr`3u^i%O<I9]$hg7dM(j(B##]&bngkbP95kr8&0O-EN-Lnl/;F1B#'3+HVDh5J$pus$OLA9(Oe4$##AMor3tD-(#chc+#M)1/#8@T2#`:XI);3a>Mf#lI)xIWx'u^0`P4m-K)5B/J-97dDN<O^=%'q6s.l4c;%[b5s.F+LsRURv?&3fuS.G^*t$E5^gLFr,)O,v_>$jtTDNZqa>N39_6&]^+Z-EL9r))fHQ'^wHd'b.Rx-+BB4MA>^;-&58b-#2R[')7P:)`[Ep%sb]U)Y&UF%Ju+2_jx,V)7ZS.-SUH.-q3n0#YU4?.RpH+#ekP]4%p9q7?iK/)v?a<-V0Y[$t7ufM,j(B#w_&`&[Vd8/s/'/-8T+BObm)'8gb.5^'fkA#?`c8.^@e6&g*eYm2a8(O0HM28iSX]YKprA#`f?p-L00`&w?<rNR]?9O0&KV-%f1p.PPViKZn#qr#UZd3w0`.3SiY1M-FcI)S(Ls-22'9%mTgU%L=Zd)5*j<%oQl)*E`j)*/bY,M.R@T.&`X]u&,Xw9L)>>#@#]H#::3jLA3gO9xP)<%&Y@C#B2()A^YY$&g7BB+SST$&gm5r%Idax']lFT*+0Q_/<]F#$3C=N0tcZ(#b,>>#Qc^KMS,+Z6xck-$b-YD#Xc1p.QNCD3#a4OO[M3e2n`aI)q.rv-0S<+3CL0$5*Zk-$DhNYdfAm302XHr<OC;+G*gkC/4>w_uxn,*(q01H)jxkZ-KwURWx=ho.%A<RW(eQIR^)2n&V;*nO%;D<MXi68%:I:`sd/020ao%XLrVPA#vkh8.T>%&4#,]]4:*YA#T35N'fL0+*I5^+4(xkj1Mnpr6=fOZIwE)h)sG&(5'MQaG$T-@-VgY/(B?l/(e_>NB6:)_.Ru_;$WbPRAf]V8&mh%T%MES+.pj8bQE4C90vJDu$U/QV%d+P?,r2949WY'X/D-;g(U0SW$#>1@-o37m/(AP##Sj6o#PcnC9P-sG<Hx6V8['Yvej:Vm9BH*X&SOqkLu*5[$r(kJiC_39%P>^;-%m5<-<bcHM+#1sNB429.?3w`aCF0I$bf69%>/TgLkhB.&8bfCMs_>;-xt4R*H'mTM:lA,M<Rrt-b+SfLppt&#%/5##Kg$S#*TC7#Ni8*#fVU:%fZX,2FsHd)lh)Q/X985/e;<Z5[q'E#1n>V/CV>c4Zp?A4PD,c4NIV@,*<7.M(=L+*P?T:%19aB%Q/$w#iW4T%?>Ns%h6ss-xdos$ge3p%(f`M0@3Es%aq7Y-[[U4+_HSs$M]%12sGCI$=OX<%df;o&me&m&mv^d2d#u=$<0Qu%wp<U.EE[h,G/L=QuHA<$ZL+N16VP/2:oYH0Ylc=l^?0GVC_:wg[0`.3kcpd4-c7C#x)Qv$pUev7<Nw,*]nr?#HXX/2I(_GNp*Ar8C,>)4O>2N0HwwS%Ep99%&^FgL?K)?%9b330^DKv#J%.W$SY@U)Rv^;$I6Xx#URHt-A5CW$if(?#A?^lS7v/6&+og--gxAmACb39%Lw#C/ujpY$B6sY#ceFv,,rjpfxA2R:;:@W$15n0#mrQS%;L:`s99=8%@%$##<IcI)PEZd3s19f3h<7f3xaok67#WF3JW&EfQ+;mQ-pBs$85u;-0LvQ894.<$tj>U)NOW8Y-@6Z$e`4eZV/rn&U0r(#xfo=#l'^E#qFX&#@]&*#eM:u$Pg8KMl0k?#/?Tv-u$:C4%[-H)RJ))3>'IH3'xr?#0%mW-Q7oBJ$s,x6eBOU2gf@d)^sOA#G.c>%lXGf&&LPB$Tb]#c/wD#PNrF*$w#[iLrJP6)3Oi>#_]2w$`v+F%^c<^494@s$88BkL+(MT.5$APBPFl97b572(9'DF*5uh;$X$U41=CIW$b6Cj$g4&x$jgtG2%`X&#nc<L<n,9%#,WH(#r$(,)gEW@,KkD,;q4n#6o:gF4s4hTp)4L+*:,l*./';3;,aBW$KI=+3e'SN'F.tp%-#Xt$1G53'hn')3kEFc2SQ^6&w9$O0V3pD&usG0(BWtH;(r9B#O&Z#Yq`OkL9s8%YnnK%OpK+kL7B%o'1v=*E)?r<1vLX&#R3n0#;`/E#eS@%#grgo.Y7fT%;opr6VHL,3]qe8%-9xb4cJ*#5Z?/[u&QQV%YeL0(B'gQ&jZ`Ih/N2&G6#2]e)f/U)F*;LL84Sh$HwsT%Ol;Z7&5n0#Wf68%DBW>#w05;65=/F,STlD#FWeL2G27C#-d%H)*)TF4KjE.3oi&f)ORIw#LE%gLxPPA#r83i2L<DB#+Iw8%#f?I$b*?JCTNKN:Wgd*,.G`;$QmT#$61bN1rYj&H(^j*-q/H=$FV?`a0VU02Txb;-^pJ;D*YffL7nJs$]uwL(&Wnx8]0U40=NbV$,5YY#BOes-$bFoL43l(.*^_U8WxBwK/jx<%x3vr-=2K+4stC.3e*H#$`,@[01B[B#a%NT/><WL)2RtEcC]cd$`2c^,;mvK%?a%*Nl/AqLW5+5Cnv^d2uvM'O-%>K.7V0X'3@CB#G=vP2Lw(kbi@Ig)[LR#M(#DHMF.43.6FHgL.Pmu>U'Vl-h6b@'u7Y/MxLL<.*c68%LNhg1Y3=&#(WH(#X=#+#9jO59O#tY-Ec;m/`c%H)+,Bf34r#<-/^bK&OOOa&s]3pu%]r%,[.PwLNT;rZVDG@P5b`b;%f(c%i+7X1O$H]uP9mA#aKC@-x:`5/P:-n&.#wIOq%3/%`ahR#1V)edcoi,<lRP)4#+ct(.N8f39`p>,8#juLiIr-M5`CJ)mMmd?Y3iS0JgBbaBC0I$29g?7^8a5:3MoQ04R%##,V1vu<4>>#bf0'#8Enb48tFA#hCh8.[GUv-h,U-%],u6/F^PH*nfjI)+x4gL*ajD#[21q'u@D>7^+Uu6*q10(vgEu-r)YA#M5dNDS<^;%LXAe(:B*H*RkuN'm%<X(%<lA#Ydo[#E?pm&4qno;;sAg2fB?eMxAs?#>xQ<-/::#<Ai,12;1TV6orX>h/G>N'V%Le*CWld*.rIrUkVHhM07Rt7E-'6&qNn8Eqq*=$OP4T'KGVN'^YJFG^R*s-pn8<7m?lJ(HwfqLFn$##w%5##eKKJ(m(8C4t(4I)1OTfL.'vl$JTjZ,bM%pCNqpkC`?'n&H/xA(L1vV'+<UN'8O^-6nV@JL&*V;.<*UI*]*'u$`S6C#P;Bf3c:pr6*)4r0?3Z(+^Z#r%[%te)5^#K)4<D`AHnA308koW$RKXX$o#pW$M%Z##B[X/15b/E#<6i$#3DW)#I%vG-ke:d-EA9tS4_tD#qcl@0xg;E4$mi`3fGBhP$-U:%>]x20<g,s8ki8H)]:LW-,0ai2O&RH)UI9t%Duh;$l=ol'l>qq%MW^U%_)&GePB(U%-*EQK^n-w$QNbX$=PAX/BR0Z$eLEAbKAWu$Ls$-)0Yn21XC^p&REFX$a2?xQ[Oft%YfY=l1k4GV-l68%=wfi'M,@D*nBIP/NO$##Tn.i)sv@+4q#G:.sTIg)Cnxw'O+]w'LLT;.^8gG3;fG<-IYlS.%[_5L5=^;-(=R20pS&pA$l]^7=QOh#d#MX(40*gagT=mLgf%N1DaoH-:Z=2L.EG&#a3n0#I2>>#'SI*.9E&,NXs%(#8pm(#HJa)#C@+F3ss5k(PQgq%(/Xi(vTw0#8(Q_+08pr-2H[.MkZ8@#4pD9`o)pk&r8w%+OB@vnF%7%-u%Re%qPW?%.UCJ)<4,0hpE7d'RCe20^Cs%,NLwhe7J`$'Wb9U)GQcofIrI&,IIH]%3vC`app,D-E*KK'CrU%6c7)i:1e)[$$d(T/ITR12PH+IHkJn^NCs+G-GFJb-O?xHH*e.D+vhItL&c+XLL#&hLuKB,.ei]VM3DdwLwH3p+%WC%M2Ko<:jfO?.qcc&#ccGlL=IC:%Fm+l9c9G)4A?3b$[g^A=Q,/(m9W07/Q0A0uO7A`a;:3p%HjfI_93dr//cRN'ib>/h<BPD3&;>Yu:l*.)F`Q9%vJcT%VdPN'86$X7F&`6&]fRs$^0SNM^q6>#;7?C+7),##:aqR#fXL7#B6_c)w7%P(&OJ@#4'6caInS^)o?/[uov&##;3TT.nd0'#<A8D:Hr7_6nM6.%1ReLM>fYA#1T6&4_wl)4Ytg;.xf5qp@M-r+3q'H2Xf?%b%iA=%*7u.)Qd14'N'DT7ho<vL%AjR#$3vN'FS,##0X3D%:/X<hgf69%uQwJVB#>_/7C)YPG&E(M'S0LV7$:<.H%vu#GpYm/`EX&#N,>>#V&/n$I'b8.+V'v5?eB#-#a-n/0Zc8/m[x_#U-US-/]Kp6C+T2'xl6w'PD@<?x%l[9#'D6COI;h3&aHG2RbUe-/GgJ)x;HN'l*%X-c%Yh,UEI<MBoR(#'&dT%N^>G2'&H9%H7<T.TN><.>$Ma'A23,)%#2bRK<KR//-8S[C_39%1o/I$bO&oS:`[@'FEt-$x[xt%Ovuan/p<s%<'v3+a:sV7-9.'4Oe/3'$3tOS8q#v#lFZ=lJ`2GV3pFLW9&P^,4e?HbPd/O9&`Y-3nh)Q/))TF4]X1N(Wg<n02w[c;dh%W$W_F^MI;U@/w''%%*O/5M4jf=-0:9Vg%<Id3Tq'H2b1SfLreqA46mg5B9h4',R2;j1`v&##$&>uusB;mLmE4jL(rXI)Xq)v#o$oRN=dVEeYnQ420;6W-s+.`&X#juL2N@%blmk6sq3n0#09j9DbUVmL/Ei'#Apgd'_`c<Q?+x9.F1A.b)T()3=vP5&`m,P26KihLT$IF<h4J'J(`(0MPAm<MSs.'5_0V_#_hET%4Se<$9%BQ&qh]%'E=t*&AnEs-H@=WOS?UkL3k#P0CGH:%#%'a<Rv:xNFG.2.XH#.S[q1=Q#mXCP7`Uh$TekD#ZRfOVFPg.*T9@+4$Ml)>Itqd-Eq7K<2UkUIfnpA#d6xI-EQYO-A'uZ-Ah87akT9b<TLO]ux7'7.U1Qm8DB*X&*Gwe%OI_r069EYP_V(i:^.^G3kRb;?QGGH3EUET%^@F,MCYk[tv=LMUU=T]u-N,W-YO3`&_MLW$tv@jLI7-##v(uv.N46>#MmV&#xU8g%kgjxK2G^f+bWAJN'`>X&#6MG)2Q8c$%i@W@;:@W$h[^;-:TRJ&kw5B#Bl;m/V*1I$#Sg%OHkY^.>a.K<l+AQ-krsv%*XNW-#/EdFIPcd$Kgk&6^NT`&o9KjD8(u48<DVG[hL`<-V0Eq76%Z^$[Uup71472L`=1E&RGY##l5At#dZcf?%.CA7;tCa'Pb[68pV%?n.=']$@slxPj`f@%'V0T76VkA#ms7Y-lXZe$C<o'/00sc<d^mA#n%H<-xv><-hTuP(u8Z;%Ra%jL@<+;.(PUV$P@Wm/Iqn%#42<)#ku0[%&tFA#1t8Y_[Q*aN]*3+(u$PvepeEwA?`KB%;xgl8Z`-U.uWET%+P^;-1cD21@2sM'BiHT%WGhT%7g-J879%D&5l7afbBNZ6Xt[%-UsB:%CL,a+C5b;%FsrA#XeS#NDWY,M^&*gZn)5s%n2w%+CF*<-'9i=%gW-x.14xC#k[r%,3GE/%[VYt-pF(J#n0De2Da,8/S'JwuS)?R&cV(##VWj-$S/5##_-ki']Flr-M#_B#6=F7/R',V/2Mo+M7m4<'FPM[-Qx_JDZVx]%IXTY%QA_$7A:cc-`VNk+(rT<nW18>-#lhl/$&>uuf5wK#5K[`%NN-i1t:gF4?DXI)C=[s$G9*Y6xA?3'R0k3Gak$t-DVi:%Dai>?`&5u-d.9+Gd_i'+`@/Y.Su)$#%Wpk&SJ###W,,h3AI1a4;X^:/YC1Df'ZoAD?PhR;-,MT.O&%xSw@hL2:aqR#F_U7#U?O&#W,1#$kC/r/F.@x6p(b.3Z1IA-3I+U%MDRv$0#bqebO7[-PvSb-Gdu9%x9Xp%.SN/20.$68ceqUAi-^j:eu'=/60Yj3P=DmLUxQ[-q]Xj1f####Y9-5.SE;mL<r@p&ucQ]4;NHD*P=.s$>`Aa#fXcI)iHX,25q'E#PaGx#,+sG;80*I-BEQJ(3wC,@jL`k@;ru>#e1b>Ye])<%;'Xn/)s7p&.OmZ$$n]f$-OJ@#U@Rs$:lnrm(po%FoeKGj9Y.R34MYO%lu7p&+(lO1^4;Zu[Z)m/+P7gU>uQUpbp4X$eJ?%b5#k(#eR/&v+6wK#4N7%#*PEb3YZTC,HX1E>,7YI)]6&W70?h#c6Ocm'OMl)3B3d('MFPE't7sILaYgm]b6JfL<S?uuw4>>#t4=&#%]#`8st[Qs&Yhp&i2/&(DA,s-1LixL1X[6/O[rw&=::wLHBn9M^L@%bfv<2URduS.tZYY#/Sk;0EXI%#`/[d31+9XUVCA`&kQ,n&*OQL-k(;T.RRD8&r@gOMg3FnOP1$##?'e3_Z,v:d.D###$tB:%,^NjL`9-J*R3;c*aO/f2d`?g'F_[d'Q%/GV@[ugL29TC/schR#WvB-MKv)oA@BT:^-q?K)6J)T./rU%63heq.Dh+%,0E9I$'9PF%Gx<#-d#G<-(u3G%L3VhLeBr]$Rk4GV<h+t0[F$m%9UaW-Wn&dtM/i#8LJ8'f0ik(N0(f)*A+dW-%Y7B-mBp08bm0B#AB)4'fXlGMNGTd'tA3I)Yq)Z6W_d5/V&>)4wli#-o:gF4o9i^o2vao7*5(B#qZ'*82wj-?,$x588=%`A2F$L>^*`B8rw'B#Q7Q>8kUbA#jqOd2%2PuuR$?V#9C)4#Mqn%#&xs'Q'PgF4k&B.*%T0<7Vb7%-dqh8.ZO84'nMM-)r=SfLqJk=Gw%CU[p.YT[[maV7++2.MwXYC5qXo0(4n*)#$),##%@mV#:#Q3#h+FcMS4W*%^S*5A/mY<.^GB:%H(@8%6.5I$=8`$'9VT2g,CWt(Boat(>wZ;%M;3;;I_P,M]P7C#)=iGMOcJ@#?tBC-Lilt8nDT;.Fj^W-I;va?AGUv-;`tw5%L$&%Xfb[?%55dN%'2$5575+%GZt;-e]MX-,gF?@B#b'O7OxX-sc``3Ew^*@>n2?HDE,n&Xn,*N#68DA'NgpT)xMe.<de12c.O$%mNXA#(PP8.;cJD*T,YD4$vsB#xmWZ%esbp%1bHgL3QN#P;5sE-V@]+Npe+O'AV[w'+$t;-`i_p2pt_qQ996Df#[2n&<,$6SR6g*%rtV[&9n^q)a4T(N_XNE*L0;.Mmpsw&,m?8@7?@m09s$f?GZaJM8*[x6K]B.*Ynn8%Q6FA#>52T.x?7f3m^2M%g^CsARqOp%bw8Q&cGiK(sYRh(7M/$5-nVD+x^]a+[JX+Nwg2]7Tj#;%PHT6&]Z>3'bClZ,R9,n&O;%1(u8X?6=vkZ-lPwTM#BKm'9>-^ZoK>a=>rcG*]7PgL1Y<78@^JQ(*bis-;tV)+UQ,n&lVjfL48.#8;8T;.S=8*+O*Lo&cjsa*Qr2d*TZ4S2;j6o#:WL7#F[P+#Ksgo.AB83/`7.[#RBcZ.$S7C#e_'0%h+]]4EDb_$'TID*@b1*Ne/=,N+@j?#xo<F7w)iw0$>;u7a[?C#NLlZ,/4$o1T^WN94=[iLn^DKC%%bN0O+s;&8XA30q-2kLFb.q.w:+.)aA[q)KRVL3rk?.NBFo/R>`3B-%0IA-4X,28H.]5'rM>5&,N6C#f:&A$%&3D##Mj/%47^jN*/65/=,1F%k(HP/7C/Q/u4?6/s`T(,$ctA#-b&O=Q,Guu`BmV#+%Q3#.,BP8pSY8/IiK`$rgGj'WCQD%Ow%],>WQD*^eWAb70PD3]W^:%Ok-K#ijuN'1YClIDT?)*q)VK*(&dY'f>QN'6]6IMV>$##w]c%b@nW/)O%h`$:(Rs-V6w+DU95H3Ec7C#JO&b-?[>[B<$eiL%Nw1KNc^Z$lmj+`g(N-d@?b<'26Nb$1QQJ(B>q8.]::8.jNjiUa&U,*mscXOpG?>#^l>xkqVKJVKS8s.6>[m/iE(E#:*YA#2UZ&%$)Zx6Y&UESl;b7Q5ls;&g6k20Y:G>#</4&#e0Nt_`)mD#`uJF*?ljj1w-@x6r49f3k24`sE#W)'<l503av-d)Ji__,&n/i3N`cY#5D6mSLl[<?sV(P0SmdN'qR,81)pB*+7;>r'w,RwBJ/###7fZX$()PV-CnCP8bw9hL)JXD#*jc5/#mqB#DK)f<[TC_&Tt;8.C9iU@u)wY690x:.r3_=%iZQ8/QG1O+$T'i)oD($'c()n/]S7p&:/ugLYIhu&`/#r)vo@u(QvJ3,ox:mXv;fGMNQqkLl3,1:aYMqMWeR/:Igk;f?,B.*8(oGt_SfF4k>a$',*9WNmpQ=l<&?eZw'`caIvoq)#JB`NT&=+Nu#<Zui_9`M)1'_-2%Ee+pWlA>b`J7h-L-]%=oaj0Lk*.)6j64'I)u<Qs)u1qdlhk+-/4'#vXL7#VNvaNC.vh%j>#:;1RvcMMuWB-wX15/7C@wuUVc)M5c6lL^8QA#B.i?#+#K+*x3vr-;'B8%*f@C#kK(E#<)m8.;j:9/DgKs-$Pd4Cv]Zo'c^R1&E'XX$#Hg.$d<<6/@o(v#MMUhLfQFp%9MvO+_eE9%pOU_Ggqhs-6NG#>BouN'+>t%%1=`9.-v31<x>j63<p+Kjc9W$#WN./&f#J32;ZNH*PJ))3?[^:/8dEv$Tp$H2).N`+r11^%tDlT%u6G^$rfQ.%GrD'MND$8/-gbQ&kJw8%,_?^4r%.GV6U/2'5]3>5gB%##)a0i)>G[Z$7d#K):M<r9WfK$&1W8f3*^B.*Q'UfL&+YI)WZ-l1x-,Q'W8wl$xFl/M#4P>%]M<C'MD6`aq+S5'EccYugp$-)Ef[a3Y2Pb+YS_V.EMiUm%M:j(clNE*B_gF*r$%=-qm2=)/N2tL;Pq2);;Zp%;;^:'-waU.kM?W.ZN7K)`SAiL,Df312.7T.I,Guu6Zqn#?DZ)%w$UU@L[2w$hHff1HdqA$#J)W-)vJ*[xJ))3N)b.3R?BSSG<@g+4^N&+T_Ep%R8P:K^fU_%pK3g#dLR42M6V,)lCx/<pkts$&=Ck1^c&'+]Ygw67?HN'?VHt$<Z.70njFc%/IVV-JJEI)olo5AWhG,*v>^)4b_pfLBnF/*,smh2s0tNGSH#s.<[-0)t#ut$)7rs-q6#,3S4642OC<P<n/.n&vt%8/?R%=-Pl%Q0IHh6&&5>##YG`Qj5@KJ(laAJ1_tu,*mm*C2BS7C#1m+c4Uq@.*s4^+4LKk;-_ux^$;D,c4#[2U/F`J&$Do8H@Ax/,,NwZS^@f;)>C,h+>M>l(5gT:m&mYmr%lOs/(_JbT13v?F%A8?<>(X+?-6>Z50GT6n&m+81(<QV6NVU>#vh>*L#k(b+.#%AnL>bob40<Tv-&9K(/qd&],L7X6D.VMB#G7[=7kiE.3.Y8a#ae_F*1Qj;%GL]f.vBo8%:S,<-HThV%KARI2T=)?#]pva3fm3vSbhfM'#)hP/uD''%Gq*T%3$*l]VF[2LbxTi)cI%8'kD9U'T@LC42^,p%G0%'5/9F20bn%oL?;&A,O@^>.=Mju.JXVv#%Csb%p*YK(beAe*sc?D,;*'5)up/W$-'g&5j^Ck'RM8'#uVo9v[v.nL,$3$#gYFb$A39Z-a8t1);NkR8w5R_#L@i%,$$W`+hGI$5Kgu/E'VOa*GNp@#HMS[uBO$Y'E#5uu)f8X7e8KM0VB')3)_Aj0Ph<Y$S$<8.[Q.U/g3YD#STCD3[t9a#AQND#Qd+<8xxkb$*mcp%>Tat0auiW%n^W>-cAGb%-<9j0irH>#uLK58F`OI#N'gU/MvW9%reLm&b=-`%rQ&AZ7%Vv#Sb4$ph0axFCWMs%Qli^obY3>5e%m%==s&##qTQ;@GF5s.:ZY=-=TwhLEJGA#0@%lLxBhl%^CE(&Ux]X<_j0B#NP+q&Nr62LKb-C#MXx[uoMII2Z8Z;%I4*Y$m?5/(Cr0%,3op'8Dag;-YMH<-a',s/_f<J2C_39%fBP)3&,###W&X>#2m-,)(Aju5;8q2:#U,<.WS[]4Dav]1j2+Z6?-YD#'r@8%R9S,X24v<-mu)LA&+o:/ZDhR%NgeZ,XocM9w>#^,G:Mw&/Qu$'8_W>-#<s]Fh/GoLPUn`,+Fn$0ee0H)e4dq&UZA,;$RD3(Xtiw&KmL_&cGwfL=;KT$)Esc<Gnu&#$,GuuEg7&%,MCL3;;Uv-l1Ve$>$:a#?W8f3g&sDS:M3u7wJc>#YFc$,Y'0GV-d/9)afhV$1Q8.**M[oL^p+O/O4>>#cs0hL$bb)#^>UHOD5B.*dsUO']`*Z%2hn,33Z$E3&.Hv$N-+V.T>%&4ch1i%SS<+3wc``3o@cvL%[fHDPU7s$42CW$ai$.MC0F7/=l=CH:MsnL#$g8%vEU=%]TAW$W8te)6^9s$>Oe8%HsUE3-;S/1$$6,6u[5_$hFw8%iPEe3/hD[$+,>>#dGiu5&$329hM/R.xLbI)dw7j9%?Pd3w0`.39F3V('b_J<PZ);;G5Cs-tdtl96w>K)[(Ls-Em9C-s8=R1(Duu#JA22Ku1TV-%jCF,[hj=.Fe75/'(#[$i<s;-+q)'%Fp4AFPX9to]wOF33.hVCUquJCCeE9%$$6K`OT5R&>o6O&?+A['WicYu1e#hL%g-X.Sg$9%tUU51h<Jj0QS5R&8cmAk<=B_-:o[%'#wcC/W3Fp.)eA`a@;H3bA39Z-N&B.*IVI@>8D(a4Ml5<-=[X8&<uSfL0REZ#IF%[ui^82'D:.s$_rH[-EGAhLmN@&,s]RN'ULQ_%<i:?#ucIw#Qm0j($[e9.>tmG*t7Bb*Qq,@-E]cV'UdPN'vBQk(9T%RNN5YY#O*[0#9Q_r?87H?&bpf@#4E$N0%]r%,o<5E#HLHRAjS/W7RlIfL;bql8_-ki'65`Kcd@i?#ZVd8/MPsD#=XEs-80kH;F%JI*gEW@,W-gP:Y0WZub7b9%/ChB#$HMZumOD)+QJ@b@r'.%,]@M-)$-9I$O(#e)kT1)*G1rKGLLKfLxKYGM3/,GM4jTn$60tKGv[e<-jMvWHmik?K-lh8./`&H>sPA3/<)]L(>(8K+X<JW$fuPW-.)&W)9;`p%c<Fc2G]cN)W<JW$+4xJM,S3+&vd(:)=FR]c6u/I$e^b8.?$X`<.Ynof0>i`&CeAJ1@@KV6qa%##jL:hPI]ms-_5L&=O2v<.C3lD#TMrB##>:8.T[rX-P[eQ2sTb4:eJcd3,5^+4nc4%?SnMw$(5IC#f]r%,p]-6MYGm;%W'<)%q3c#%4Ju:$)JZ+%'I(X9iE<*>r0P4::-Cq%c0FwT/X1B>hJZ@-CUws$N=9mA.)Zp%(k.T.N>%+M%eB6C=01lL_j49%ZgGN'tr$;%QJ-<-Yx<'%2lh8.$O]s$CQ?[$)i<N0i?85/w?uD#^JleDt>Sj0n@6##JMt0(stvp.r[bQ'a0TN'ZA$-2UgZ3D4i4',#36/(Gbv]+lVQN'7^0R'75?9%-'=J2fLVb$q27),)Yqr$2)qCam@@]bL3DP8:*<VQrk#Jh>kM]F4_lS/'U-9/x3YD#G1E&&+9LT.bf^I*31ai-f85F%6[X,2h<2-*Zj:9/xO&Y(;-(kbE(6j1g4#,'5nK6/35-J*:wW]Fc+Bw6Y?&s$Wc]Y,xjFAb@&7##Lghg(FL*T%NN5R&-Pc>#N'k5&=^OQ'LR*T%R]pN,D6'7/jvj-$8Ol'.fCLW-x9mc*&%w5/'D(w,wVv3'fZ1K(r.1W-hC:<-x?))+&(*6/Z:[s$TDOgM;JRv$u6I)*g8JIMS3xo%]/[ROOCH>#D:R8%MBGN'[5rg([^Gn&M$Km&FBcj'A-Kq%@e<t$=$FR/^,HR&VK^6&?'7$$&;+s6u$-K)&*(<-U@.-))Qh6&w-%t-A=@8%An&U%w][L()0fa+rt$=-c/H50)Nh6&u'rs-0td--bI3T%i+SH)uQj6/_#qS/iO]I2ssuJ(t'ADXmj/6'M*Tm&i>@:MX_2k'#^p3+_M4oNX5YY#Xic=l_B0GVb6ai07-CG)SaUX%HV>c4>;gF4@]^F*#BPI;ak*H;lYWI)@FNg>Ab:k1,GcY#qja6/Nuo-(Dr$W$AMU@6K<@i(#UEM#=X2588e](+1lh;$aNZH3G<7cMh'X5&cBh41FdwX&lR:l2vxm]Jf2_B#ZWL7#1,>>#j_@T%*#*D#muU4&J'=?#p>Kt8>VCXQmN$$$T'DeM->?uu=v5tL_S`'#iYl]#(_Aj0qkSH$<8Uv-#$U;7EwBsH;36p0iZI*+#n^6&ru3]#Hnn@#IIhH24J]9&J=D?#K/*Z5ePT<-,*QN'k=OG2^cd_#Pba6&bqStHDYp0M$ZiS@A1Tg2Hqco7a)L-%)J+gLuEM5%d2Cv-wHeF4n[>l1D4NT/4sD<?vp;Q/]aQ)*Ui?<.Qtl)44HvA4f<xl/TvrM2+i9K2o*<ZuHsRa+4uvT.=KxP'^KC9MGG,`WZhiZ#fEph7Z%O.)+T-['v`@P1A9S.*Z2Wo&@inE+@dG5&5uUs-Z0^r8Ugeq/8Ds209YgF*<@tW%x_JfLHIH##hZ(304pm(#2sgo.59U9VFR8t-;*qCGf_;h)4(XD#u?lD#f=E@GNwkA#sA^7(=:W?G'?GdNnqnL*83=P<WYnDGRZ)W%X+2%%3FwX-*Bp>GTH_#v4Thn#Bpq7#_=vi6B6OA#Op-)*dPvv$a]Q_#k<85/_MSC4+xPs6EZ;O+.l_[,LdVI3$gwF3($Us%=1I8%C,598b#]P1@*>k0BT(<-B'`v#)1A.E:fqV$6L&m&;,AH#:mCn'ouX$6c;NW/g[W#.#6o;Q#(6e#C()?#(dQ%$4Sc>#e4'-#QlRfL_$/o#1>484;,>>#c0/%#CY@C#k%AA4-PsD#dVm'&tGg@#j,ZIqiO*a*g;(;(LR?>@:mc9%pb@@#Mm8ba9q;IDvFA=%:g7V@VAWK(-gxfL*'V)&-F]f1QPFb3)5^+4T@vr-#Cs?#rH%x,Xk2Q/S42t-m-_U@U1Ql1>f)q744@<$nCHp.aCsY$wbYM90:vi9M<C^u(h_#'/U;N9]jRF1+(Ss.LTK>$r%ko7NeLH-H'gZ$-n35/YvTt-Z[B(G54&,53XkD#&v(1Gg5x6KaV:<-/a0_,G&H7,^'.%,A<QkCV1XA7YjuN'0/VP0(9g->w(L^#ZA)4#/MDp.6KIV6uk4WS$<d.<sBZ;%1rtA#bJ<qM.IL,3BSd),kCpJ)?)baN,JG8.YhNt&w_9^#p[V*I?#;`)[]qf[E#P>?Ws99.?'HL2bu4_J[gPEnHHc%bxH<8%p/Yc2]/j@?,tcG*3qa)4nPHN:O$pG3=CY;)W*J'//[v)49s'H2[AU8I;r/6&0a_bSNB9;ejJ%U.&.[Y9.HZp/tLw5&Seq@IB?xu-rp58MYn,Ge2=_#$i81b8cCh'#g_/E#^)V$#h^''#4<eM(]>Cv-7H?>BjJYA#Px-<-YD-t$DJ:W-(U%ktB(?V-n^@EH)F46B=[l.),J`wGMm;voCB?#%uPws$%2D,%Uw3GN2.(585P^N*3u`'#&jKS.hlWI)HXX/2wLrB#I5CI;Ho:T/?D,c4M_OT%o%AA4gEW@,C3':%>%4+3Gx%B-W<'q%,?%,,_Vrg(Hr`U%&@7a+IT-caF@1H2W5i0(DJ+ME#1f*;DJ/**_lf4(;Xc2(rM0`5.'Sa+N4m)49nP7&GgKA+$:YZ8qdn6%ml;]b_*%##&$:u$eZ/I$)LA8%dZ/I$Jp/KMA*61%tg;E4Nqu8/[#[]41Ngs-)9jhLGn3^,Mkk7eq<#3'7'iG)-Z^w#M:0O1[pG/(2@F=$4#vT%^iOM,IpoCOOOl_1??xP'P8:[-`o#u:BHGK1tAO/2fYAF-v:uk%uc7JL-qHQUjD(u$l69u$2RWJ1*v-Q0:]d8/b1TV6>QS<_@2'J3#r[s$(J,W-(4GN+xlmI%psV]+RSc?#Y^cN'ug%E+fB></;L^m&&ejmL19a%,&WKpRZ+b1BYAVT%)QD0(Dlgas1E,k0r+NW%9$+U.=q8q%_FQ3'V;il0o+^B+W]jAH42Y?M4U20C[6tNL*)7A4b3%##bXNT/7Dd-.tpN]Fs2Z;%mt7a4-OWh#1Jh;-cjlO'%WNU0mM?tRWlx#,n^kT%da0I$mBc?.a(cq/kK>n&M*92'%GM`+DlRBQtqgB+m5xD##msa*V/DL1_o0>Z=l(v#AV<W%?9>k0n%Sh(U<<r75(%2h_uS'#&2P:vfK#/L<c.KEA%x*38j?A4,Bbh#7k=A#Ynn8%r-ji0Fkkj1Q^v)4fnL+*7Ag;-ipXd85qfcNqBo5/</i#$&]Bp7>ElA#pl^d%E5rp/x:Hs-#V9p7OCG&#tUB#$fH.KEDOB(4dI+gLc#[x6x$V%6.e_F*1Uf6a&Lj?#ILZHd]]d8/1/w*&Jf0wgHV%<(=PR#8ekL/)9vTUAQeit.Io9s-;va.3&@3Q/cmZ.<ZL:a4859UJ/0(<-nM.)*w%AA491^?fQ+;mQcacH&VVGj^3r8Q&u3lGM$/K;-9`><-$*Zl0x$0/:UQp6&@:Kd)5bd;%l:]>-thF?-LPvL'91BQ<Oo5J*6`p>,4O1x5e*$aNEJ0BA=tJjGCr5#Y%bsM%A$1P:NxcG*QOm_o[OGKds*gPScR0T(3nAEY#f<mJTv:T/&Cs?#Y*l;':,52@KBPgHhHw##B;eS##*Y6#5rC$#Oe[%#q&U'#6pm(#b,>>#cS))3Ua*c42tB:%`im8/9(ro.s[Sq)vu&f)j+DE4D#/H)[`OjL4>xD*22ur-#K=c44;8N0Sh_F*NUW`<IuW_5j(`f_:B1R#YVh9.@adOo-KQ4*AS;%&OS>v#p*t7MLuBKM.VpVMQxiFV[>+D#09f+>itY>-+5Ge@bO%@@0jD1;e@o0#t'0^-&9+jL?v%mK2?%j:]IVPKLN%(#%2Puu:g-o#Dv$8#;?<jL2+;u$a_QP/#Zc8/i?85/%IuD#iapi'XAc;-c;q-%l-Mxt$hI],-HhB)g7vKh%R``+F+av#mVom8*&DZu:3vN'DBT]=uY9A,+QgB)hq;hh'gb`+OkA2'nXgW&u>>YuwI+Z-F9([KKGY##'63a3/N7%#,WH(#enl+#D%(,)tfrk'+,;h$Glf`*[0x;QY/L&=c=0Ce%kw2&$?_EEkF7'P.(VJ:D:@<$25ofLm+]D*u7@<$.%D/:KFjW@V5do/*_7P%8hvU7,#=a&R*'=$3sf6(1;TkLRno<$+[#B$en(C&5j,XC)DofLGCMX-qmi3=7-mwf5YaD#1p9c`AV?`a3S###&r/l'OZ'u$b3NZ6Rg;E4P/mG(d6&U+C0+K_K[%@#rK2K_9?l3'xi_m&*QiZ,4U9g1[,=##-^-,)vsai0OB;W@#&'Z-*]<B-4Lb,%piB.*#(>U%m_j=.:r'ga^ia1BsRB.&ElZp%8]+]uNlQb<]#/=)r3E0Gcn3R/jt]V2jcO,iC1Df<AH31)KJ@I2d.$##$,Y:v;4>>#w=a`>3FlD46/[0>fO)d34D)W-Okm$IeDA+47OJs-g7+gL%8Ig)JH^@#CG0H)0P_Nk[%'I,7&$9%V3=MCK:lgLL0W=-YZ+Z-L[t05o&M0(57w7*wNvek$HxK#kA@g:8(R^5lQ%##at)3Vs+Ef%13>m/*NQ_#3wlR04=hc*ZM6:.a=@8%:AMQ/tS39/oc6MTW<d@-.)34'Gr?=-Lx?uQaeEZ@QcMU8%s3d2lkMW-+SOq,J639'bv3V7,m2O4sKhQ9;SS5'C;$[-L:/R3X7+WBsnLJ)7LD@,b4k0(HCA>.v3T*@c>2K1;^U7#>=#+#N`aI);RZ)cAAg.*6D>8.B.i?#l=*N0i.<9/jq'E#*VmLMNxc<-Q+)X-&:H90QDL[-eQZ*7hY#d3LY%9.o;d31lqkd?:mi,)1xqv#M'S@#I5,j)@ekX$<Usl&n,0+EZ?W8&_g)B#X;rsLbj^VKs:(X%lcZr%37(x5k2S$9O/mX$EWUg(_/20(Z+K>-v-RmL*O$##1^-/L6Yxx+$N08%]2Cv->;gF4kJ1I$n]B.*LP1I$<eYI)5lei1i?^_u%i4J4p[,61cOi@,g/4o$&[-)4.5G22/5Mv#j95X.Pa%k(%5YY#.)Q%b^ZF`adnho.6kS,*gGD]$8l7pg70mkK=Vxi)UU<9/DcGg)JNj1^5>M^uZ]<-*dLPN':uvAMkOqM^Fs(T7me%N::X?eSf-ChjmcQN'%,r[%#'?F&]++,M$0t=c`VAT/4MR]4Q)QH*i:Ls-^mh;?2vxc3Le/H*JA=a*m^49./)b.3m=Y;L4tQA%n3;CX>HoO9%Xt:%rbm(5$21W-$uMm/k$'k0%Y&m*>Ikp%<7p.)dg#30FDTT%7]82+C^8F.4n&Z-V(I]-2r8U)qEbp%8*uZ-EE++%/)mqpkt@`aKVMJ(sp&/1JE+4MuAlg$0A0+*>G0+*8U6D'QIV@,ZDsI3X]OS7+eYIqSQ^6&LW&%Y+%0ON%+P+JEom5&EH;O+s$/A&v`L[*v&loLvwO_NT5&@%EcKB%<#R,2SBb%bUe$##+lm=7No^I*QkU,Mx]YA#O7%s$@OPn*%n;ga=%=+3N;PR*KCAm0M=@6g;1*Z-RjjU7f/.)*6[NE*(P7)&H2,j^xd8n/R^-G3a'JYMAVa]1a<=nKmXRv-,P3/`i7wK>T@4a&[ggQ&GJZe3v12O0';lgh.1wF+WX<**nY.^11qll$_k4GVM8w%+KF$##a(]L(oFIT.l/^I*Sv_x$i?Q12Z4.f;7EY)4Qc#bEnQhr&k&RQ4t'Tu.$hU;$%74n&W+or69Qrbrg3Xs-Aj`uLkW2E4bLofL20JHDJ%p.CS84m'bZT'F&0@$$vcS=ukm:GM+VN]$Qa5F<8#tY-x,0W-NtY$(9CcsH<uv4a6f8;6ciM<%*A^;-R;.39wt2D['F5gL?xJ%#,pm(#,<L4&9:.m2%xbI)PEZd3Hqtw-hI;]P8^Z.qfe+Z-ntan3WvBf$[/Zv-nCY.:i;CW-2,3)#sBV,#0e53#$2QA#vkh8.'d0<72nL+*G&9f3fINi*Oe&>.E_Jp.1[ih)Wp'Pk3E>MtTxTgM2cj=.1@%lL6VXD#QNCD34Z#K)?1u3+ru.&4NDn;%*e75/KjE.3^W&Q';u7i$s,+T'we9f)HCRs$Bb<T%M_wS%Y%ffLu:xD*xKUV&b=q*85,OKVK99U%6iLZ#wuPb%QuE0(f&&]%`O39%J?5N'k>ik'SW#R&[gFT%vdln&`<49%EXns$?eNT%;R*9%:i.R3Xfc>#m'&[:t,6De5Y8U&&UA[0;'OZ#mUdL-=t$'49MlJ(X_R<$=@es$Ljq,)Ua^6&s3^*@^.m##sL'^#dRas-QcGf='C29//W8f3(O<<:1J@e%U9ki0bl@d)o2u]#[3rhL7@,gL.S7C#t0qg%(91#$1xvD4JP-98KIo/1]kjp%P1`[#Khsx-/Ktp'Y6]j08:@<$=kH68oS)4'Hm=E$LY9h3%s`t.JTOV.ITG3'@-J>-;#mC&5Z$v$PbW]-D%p+MGt]@#u?1hLT^l=$bO/n&VRaO:Gj*FNsjk5&[oNi(9kOLs.S%(#h4_,bnRY42GSR2.wRUA?$O1S*@Zc8/Ee:N;PY7Q-.<bN.9>'32=xi8Ax;mxF?1/ZnHs*b$,V4gL++Wh-9p9s7T%*KVew,?8o:Af-[W(n/E@%%#Uqn%#C=_](^.j=.JJl-$+EPF%:Q(q.av0XV,6=I$G7fT.dPqvA)0#)Ns,/o#:WL7#:aLj0b$(,)>V&E#S4r?#-@d;%21)t-p)K#G29@b4No^I*:IF<%T8X>-2YlS.I@S+4:>pV-Menb%o(np%/]=B+?Vmp%pd/F%dZSM3`j?QM;&j0(U?Lw-@v'<NNbRO&e>C[-at.F%^]Tt%rp5%?'/###gQ,/LuHTWorBJ;8kWnm0abLs-'J1gM]m--&GNCD36N.)*w209p=9g,2/A@<.]b2D%mp'H2eBj4LDYm4(.+CJ)?Z*%,+=D0C/ARq/Jg4',a6&+%a:d91_5u;->*.'5`#u-$fkS&,j@;[0668.GdtNQ/dDD-G)Yqr$tCF&#SdT3LFZCG)^CPV-upai0Pgcn/)87<.K5^+4TCKK%OPMx-MF?lL.5#]#bj*.)sGB@MQQ.U7Ng^r.p-.32peAC#6A76/`us.LrF4cMWCPS7H<7o[)Ro*/&$)ed6]aOD-n2&l&BFjLs@88%`3>>5/1NP&WkQX-nl&-2RRA2'i)^*%o;Y'&G^v%+;Oc'&AI%[^OY.R3Y#2R3Xx7R3Sk4#H-q'B#wLp@Ofn5HP>wJ%#b^hR#3B8F-*vv*&[:;(/hB9dOmD8F-NV_@-NP1%H@]r^QW`U@-_(<..kF#m8ZA,'$l221(9Uw9.0^k-$7;?t-H23L?G.(B#Qrn+MPL$##2u_vuQfdC#_:cK.rjP]4Jc`6&3N:u$'1R0u.u:Qpmi-9Ihi_8IJ*pi''ndENh[Zk,S5Tq).[a[&R1TgLM?PcM8/&GV,Ih4=`$E15L,>>#g4Hxka(o9MbfMg;sikA#[XlG-_ur&.F=[iL>9Ht0QYr.L'8NY5Zg>A4_jIa3wHeF40U%],vq-x6FN$>%CLD8.9j`]$SUpZR>P'B%a.+Q'vc4:$Y?/[ufH6;%nsRg#t:'f)X;%1(Tn[w#6J:E*su$5J;GBJ)J'.%,1^]K#e6f@#/i_;$<^r%,ajJv#C>&d#Qn<t$D'0q%Bj:SCP7XX?r,@-)Ur?0)cT)<@L+2$#jHZ'#B;eS#4ZL7#P6cu>SPE$6urGA#_j#`,%+di9Xg:E4nGUv-C:.5)=BFQd3Er/193]5BRtaM#nqis9aS2W%?2@Q:gCQq0CA(b$oj.P%_43n&pPrB#T>vc7L/H50Q>S'R/Ke;%D(YNjBN4D<hC(a4^_Z)%G40K%7][Ks7[@q.V)ZA#tA?h4gN$`4NNg@#Rr;mJ]V*E*`qDm/7ijp%o3dr%W(Mp.R6pZ$1b:O+I9k*%l$x8%,mhw'w;h$'K`8gLwAC:%SSU@-wxtkLco/gLTIG,M%EUU%un%jL4+e##$,P:v)-nl8SI'&+=oOg1vU`v#?]d8/S-Tv-=V&E#JAWD#&ur?#iovN'E5;N'oTxf1_c3t$Lt@8%F2juL;riB#gX;Zutxcn&VpN9%)L[W$wHP'At.72L3Iwm'H3%29;R^`*xF3R/skY)4u3YD#DnFR/gEW@,J_j=.u+[pio+O_$bDRvp3ci?'be#nAnEq2:D<%td]:,HMPX_vd:SAeaCJG.-t,qhN4.x2N4Gau.BExo'iQGx'[L9l'C3IL2BUR'OWk,L/$&P:vUQMmL]'j'#6sgo.?ljj17@[s$vZhk1IYbJM:X7U.kHuD#bLC%%lESA#oiE.3jg'u$a%NT/IV/)*a^D.3&iYS7Rc/B+W/v=$:i_;$LQYN'mRlv,o30m&V;Jf3S7V?#7Us5)<@G)QnH,L(>DQ[-tTJW$e&(Y$BkWp%9d<9%EMIm0@U<T%P<K6&$Q#w-+,)X._Qt5&i38B&/fDB32`;aI83Ee-?,a4']H,n&VAEa*URJN0U'+&#5vv(#q*07JoFlD4,f-TKt:Rv$n5Q-5>4bF3$%Im%kofF43ZWI)S/G:.2Y7%-#mjTDSQ^6&8gYn(kemaND9nK)bDVO'Dda6&==K%57dfxA'lg58r3kSn7qW`<&0X>-Ot4_-gn'<.NJdSdCk(B#C.ugLbPwv$MeF?--qx(3&&>uuEuRH#GtC$#tD-(#G@-lL+Ds?#EP5d$^NeF42%Jh)KFn8%kb>d3s.<9/1X+W-hX[?TR5^+49];QVT,MK(80`g(8GX6;&_Pt.]ZJq.>FG6*';IN'2-f5/v]/B+b2?V%J;)kDHS$03+oH>#CQqwQ&CT88tvkZ-0oYkO3[YfLQ*88%2Q,>>5#pSU1,7a3kY$T.A5B>,NE>[$hc``3_raO'V2BC/gJ^.*Z+hkL.mYhL9^YA#Z%AA4w3pTV%tFA#pkhc$1bg34PFNT/D377;sA.hsb2vN'-jHl:?v5iTlP/N2E%4j1#?dn&L1ID,E2&#,'QmV%.[DW%T,41)I7'?-1W6caLDS/;IDTh5o,6-V+;&P1(fk.)*pS[%T80/)>tmG*U)_A=<n86&XiM[$QX1R'1u?8%@c1v#;RZ(+dL)Z#C1)?#dHfN0$f4p@sAU'#)n-58nW%##L]]iL`Zh586I3j1xH&N-o)MP-V]Rm-)Cl3+l^D.3]AsS/hO)W->6ap'pn>Z,8tR:.kHuD#eERs6j5S[,Z0;U:aXg]4jYt87B%2v#X=lv,9-&'5/rXgLI3/X%(R:Z%[^P`#kbfi13AH>#sZBq%D7;?#_Ski(gt(>95AhW&ZtG*&l_bgLe'2hLdonPJ:6ZV/(0]fLvDl5&71%[#d>aN5&6Ri1m2ZBGE,Ur.WYE^-@UdTiRkddb^SDs%Gp?D*D1$##a#fF4Rq@.*b&%d)_=pL(jAqB#Z]B.*(5)U%YYFJ)`(6ca?rHJ)_**%,_'3I$E%X>-E-?d25MmH->n7>#`7blAm9+7,p;(C&IkH`#9JQ%bR9F`aSb`i0[03u-qVkL)x5N,u-o7C#OJ,G4%v.&4JHH?.dcQ_#lsOA#*w9%4k1&*&n%sILL'bp%Fs$L(vO(2)ZHI^5#NVk'PcTa+qwsm&8t-L,$8D?#;?sR8@=`Y&li*.)#qf/1PS)U8Mc>##vPW@t06ea$u8w%+JC$##nlMq%e^(6/t_g/)lZD.3rQ.0)_x;9/:%x[-jFn8%JS4'5pkK`N$Us-4&VcjLN2xE+/kA[uYv0q%7MuY#.A%W$ic^)5LFXN'L=ht/Rn62LMJ)^u8Uh:%bivr%A`]&#%k1iO>j@iLU>J(#P%T*#;mk.#_0eX-29-/E]pUNtp,_20_R(f)G[=%$S=AUL2,%E3<?HK+;Z7.MqJA+49)c.-+Q?*&,'IH3mPk<:_Hm(N?S;dc4+IF5$RUo7[d^6&Y*g#GHfT>&3Es#P6O&n/n7de$E5/q&%/w'&[xi5/bJ%H)w-,gL7KuD3.Evn&OnSN'<kuN'8V`6&1oB;-fNPh#A$Pp.X;d+>'avt()iEh>#,F$OtKHN;J/72L&4/T.mnl+#2sbi2(_V<hR]wp;)X)B%fU]W.,-PY%`%,)N26pW;W'Ucje8=W%ACm.MB>'*'RNYV$G>r/1A4i$#dWt&#.I?D*k0bq%mEjv@C/.a3&8/8@FWC5iQc,`%J)TF4JYC&,^'.%,f@wmatPi0(=cOo76F(C&$9;s%k)59%.w9H2s.rC&S=LP8CMO]ucNk<)=4=;2ZQd&#S(4GM;JxK#<*<O:]%U^#^0D.3,(Sb/a+x;%+QsI3Gb:T/=Fk=.U;1a4Z7Tq)rMx--dEcF3hN%pALLje*@/ue)p)MU83'1H21O_X%o%KN2&gwe)_sqI2DR'f)9=X&'/Y,Y&.YnS%i3G/(iHkhW5Up>(&I4_J3Et$M41^%#t8q'#Z*N$Sa5Hj'LW1]$^p*P(xi_s$x)8f35jic)J=Y5A@@^v-[5MG)64CB#S9>F+3hxFY`&6/(Sh;mLr;du%P,kp%lJCPMdqblAckGn*MA7Q0SQ^6&=pXe$wnIaLZwV9+'j59%Lmr>P>$A@@_9W$#ACPkiTFw[-@xq8.reX;.Ldf,DWX=veRq]:/dWku$%OJ@#$T`%GXH0<-M]U4&o9jxFH*.%,aeo&,s<9a<ds&oN>(e7<6J$Z$]Up@>:LjV7e0^['@rQ<-Z8L)Pae6##[<XA#/r@-#cvK'#X`/n$/grk'Z&PA#k%3+P#oW2Kg+Yn*C6ev$+Z;xNA=a5/A*Pv#oNhhL8YdF%t2-aNhEx8%W225gA+(h$O)Tp&%eQIMW&xIM8,+E*-c.pAsCRq$WL.RNKJxQN0MJfLn,-M;^^lS/*K#a4E26oAcKWv6.e_F*-?VhGdh:?$A:rv#jRwqMO_gLQ*pV;$XQ.?nHugX#C[N1#au:eklx#H.>9EE4.P'<&^@i?#0OjBSw5<#Vf0tF._+w`a&<K?PWpDv#nKhhL[Lb+.k3]uG]HwAIXt%s$JXY)QBjAvP<#U^$9#4(8M6U'#<_R%#-U2W#1M;78FKX>-pUZq7X.6:;OBo9;RY8'fIAlq7Tt8m_aU?>#&E1;?9Wol/c$kB-,`9=)wR2=-/_2uMZUdF%+`JcMTe8jM%<dQ)8B0=-A[aC(H/5##&5ww$2i18.I06H2D)aF30k'u$ZVd8/u3YD#0`7+%B^QJ(hH>/(.+CJ)Fcn<&%<(d%C&:@M0QIlf$bA`a*JS+M<-VR'upNh#ZhCJ)?Z*%,91C;-lBR'd+1'/LQ7FD*j*io.%NYn8/B(a4h@9=9^eB#$;<<`#ur)6/VdDA+I0vip:9wS'M^_nulJCh$phtILdNl/(NgAE+N'KQ&Yer?#DS4Q#SB'g-2FLFl#7GcMCX@`aL*8m'Qa_.4C2_S%3ZqD&oXp.)=9.IMMt@QMD9QwL1)I;@r(U^#9DH%b`dQT-u#$`-qUq@Iwg^C-f(@A-V@^;-J$LOM2]ea$E&3>5&_'E<QPl(Hx:Rv$lZE.DcJw1,JowJ12]v7A0LPN'^]/B+rx7[KNCmca:M[w'ql]0q1Da6&<CW6/v>rY(hoU7AK4N*Icc1<-[1dPO8xSfL2=FJ-:J+/%:(lA#waFVMhsJfLK[d##kw5Z>^iE#-4AhW$a-CG)PEZd3=Jsr?)F<.+OEZd3<%P:@t>pV.>CG&#..LB#_g4',i.(0MQ19ooxIO]uEB2=-?%mW-F=%+%jDIbMEXF`W#MO]uIFf>-t'^GM>Z-j>QgkA#m%mW--0oO9u?M4Bv:u5T996DfFl*$MVB2Df7xXJC.Y4_f*<*s^JgXD<b(;=KEU^C4h]p$n)c7C#^oJF*35K_836:>>(f>C+t4de$U_Es$^@U8.nUX5&d9fJ1jNAF-X--h%hOsRS>F@W$)VnQ0)Cv;%N6^@QT%oM&#&[-*Zj:9/ql4Z,%A[=Rb,wF%m<oJ1?fo8%xCiDF'[4$dG-9U%R53K(W5L'#IVE#-8ZP,*>>`H*axrB#n&]F4bS0dMtuFZM-6L>(jXo0([IHp7AEiBo4g^>-JedEM[SQ:vrtAJL@4JJ(rQwd$-C')3wkh8.ai?<.fmf*%9)'J3JQfS+2aoDN^DRxkew,?8GKDU@o7g.Mae6v&Sq$iL.4i5/;<hF*8vCPM][blA+=$-,?KIiL+sBSOSSna3+_Xv-*BpNMVQ02'u^6'#<qt.L*_Rc;J@>=7qneu>K:H]F&]+DNV(e+VpU&(QK9AG;Ej,K)T-xe*=J0EWWs%sZ9Z:@-?F0v.Tr=V-4lxI,f,#]uhhOg$RZpSROg7o[/f@1,uS7p&GmNh#wKnBA/&o]u5j=A#+[OV(4g4&>'a3KU$O<;$A]H%b=PZ%bX-]f1Z1*;?TOU[,)2rh1o83oA5Q[_#8#wA4&_D.3m&p8%mFc/M&q*Q/f?ng)^0Xn/h#,J*E%B(49S,<-uTtr.6(j3&>tNh#[brF(u@D>7^(Lu6*q10(vgEu-qf@l'Ko'W-sW-J2veH<.g3A<.be(t6bFT_4b>hZ-bX7<.c%jP0CDlY#S_`mLl_XL%LXAe(83[,*nVo+'sXkE*UN#n&vIb'$f%GBOu[V/:#@pa#6agW$rtRO9,FG'$IGeB4#:oO93[lB$%2Puu[-Zr#@$Q3#mABjCD55d3(6qWfP;$^=>MGH3LR(f)2Pw_:$mXPTBo1]$sK/?#]/)ZupluN'iL=:&CS;_ZBJ(@MW;4/MOQF&#wYs[tj)%)NH)UP&jNai0OLvP/u$:C4a?T:%YV)w$e8v5/a&ID*v_tcMKu;9/Fi@m/*.qX6j)K.$?<P)3atep%X@x;Qi:Jt%AWW#&'HAcNR1_KMbiTm(`2Afhfsf*%68Fq&05qDNp`ub%l,PT%*Bdp%g7KgLDer=-#p5X$)b`S79VAA+S_$##e+h.*cK0#$Ynn8%hu+G4QPd'&EJ(d3bp%gL&E6N')?WL)1uSfLx-RdN/k8G3VXlJ2k<O=$>sq+,aO3TIv_Sq)ss3`%YNW&FN`cY#7o1k'dw=40pgiB>_Q>n&.Po#>7;QmSeS?;%6U6L,mu9B%j`ja*q74hLXl;d%[^8xtAj0p%R`mi'Zg>A4QtfM';1TV6:]d8/O(Ec`:e4Ea+_QG*hn)8&YVo*'#/b1Bc]sA+8XBN1pQCp0$&###BaO8%#oW]4rroO(>j(:%2Y;e$3-)B=BWxi)o&[)48(]%-Jtr?#,NtM&rHjm/vh=:&f-grLX_VaOiR@66]82o&;2L]&>-]u-U.0vLZ*]S%ooOX(lfFPRMbdgL^7#w5RcBK-xs(64guC`aBLgr6ccp(<83LG)=Fn8%e^/I$ro=Z,3lWx$j+]]4`LTfL#(B.*=?a<%9C[x6uU>c4?>jt(q@:P%+;v;-lS[#%O:6h,_pC4'jFt+3Y/nD*5>'32u_^'+Mej/1WXc@5#aH;%Zx+C+@h*R/gUIq%ZS<E*pY2Gs@WjD#Jc&X%5)f-)8:*T%c9&30gK$1261?,*x%6N0QE5-2U8^;Q9]1v#]f&b*qt0j(^sE/2llXs%>^iUM-)[]47qQ(#&2P:v;'W>#R:FD*<@,87_tu,*g?FW-'KL_&PS<+3[<+J*/Tk;-1R9J+Tq]:/lD$X.0d(T/,$ea$96.)*pEFG291k31T'*O1euiW%BPZO0TfAX%Lw/<RH&BP%/cc.:97Ep.Ag'9%ib^-6IlssLbe(HM;nhS05e_cjnKS:.'w&9%fF.K)w3P,Mf2D:%=WZ`*`k*5Jd/020Tb$##>R(f)ffS>,sE9V%nH:a#$p%&4nGUv-;l&^$WP[]4d(p>%%XXJ8KKds.Hk%0:h_:w,%rp+*C=;@,`v_,)bEjv#>?xa5+eur/*u*^7Ne:J)Snj5&S996&-Dao&bV%l'vrI-)R^=?-s+aq/23$A0=ESB5wX15/%&>uu'Dt$MPL5&#+kP]4>YqH'=tuX?XebkO38OI)K-kT%,/CHMf[^vLw[q@633iS05hoT%Y%vW-8bWF%)okA#7Ab7/4.%##cq0hL7C8#Mefd##ZE=VH'mB#$kwr;-<_>_$c=g>2[x):8W2'6AEuLQ'2PRN'jHg01O-e<&J1)Zu8^P3'q<9C-r5Dx.Y*vu,<sI(H*Z,5&nP2tT+nV@,E%o-dAE/(OH[@C#s2lc%ex[]4Z*Mi%L)ZA#pXfC#-njp%h*<I$vHt9%BXw<$n/Yp%jGi9.Wfn_-n-PT8&>'i<[M`#R#Y>;-jpgp.B8%<$kC-U;`8h'&%V9&G+a_c$3uQD%IZNx'OJJ'#%&>uu<4>>#bvdk@r*@#6YqXR-1T@ORJks.Lrn-#(tHb20qF24#Rke%#k>>U(>>Cv-X7Yd3p>E.F#^Ps.V8xb46o1JQ,slIU_e`W'@OJM'^<Q_'^3jm<mfnlP;'dgLYl'0MXD7+3J(nm<g####$&>uu&b/E#],JnLDsq_,$*oq$O.,Q'Z)YA#.Oof1p:gF4>04W-D9n--+V65/??-I2=4Tq)&c(gLQ?CV%i%?87bj]s$lhF`#di`o&JPee2Xw7@#7CN5&Rvb#-<d#<.(JOM(Ptl)4hb?U7Ln+',D$Rg)h(@w-^Vn-)'a&1V*+H_+Qdk:.dbR<$2r-s$,d-I2%5so&+4iw,llNI)0l_;$1VVQ&R<]I*?Qi?BMfAL(H[8m&&cG29U8p^fB5o^fh'hlAP.QT&`-%##h&1W$XEW@,IUvLMWBo8%&p._'ff%&4;JjD#;n$gLE7_F*V[J['VSTw<rTF+5v,`v>lvN4B&l<(5wJ69%0o#68@rlx%@Ver/R;e1Mk^w$&UmXpBDN%1,G=^v-We't/]%EW-(dWC$4f=M23>###u]x9vhcaL#fYt&#oPUV$O7%s$Q0lNDcV8f32Pr_,J<Ie-Gj6XL`jo;-M_t0(@CJH*q%K+*p(5$g)wk#'V^pm&`@)+%`Qhr/3sCY$RjMqM0jHeOI)Lx$>>.;%0c&1(^rA'+VLSuc[?cDO31IlL*-R_'$1mC+FZ]Eelco2LXup<%Z,uB,N7QP/Hu.d<JR=6'NO$##J'KIEb^Gs.(PZQ<WU$lL(DGA#&1d]8&+(f):3d('RX&T.ETAZu-5`T.>P+q&be6#5/h=A#+,K=u.+CJ)aZ=01t*6K)6v-n&UJ5s-+MJfLJLQuu9dqR#xb''#FPj)#l-(*Q)f@C#bTIg)PxRR&SGg+4cU*X$hHff1tU>c4:jE.3RB%f32]Fki`S-C#AZET%Ypom/lJQR&+VRD&()V>$fQKu$R-9q%PAeh(4X?>649/&,<IC;&:7Lh$WN'P#Tqvc$J6X]#e/2g(dOhasSQ^6&$h5Y%Ir6s$Y)mn&Ngh,)MW7_+W4#2(`DqdOW_6##;j6o#;WL7#[J#lLud0`$uaGj'p;Tv-C7fF<s[,<.T>%&4DIse$f]DD3agabNM>A)tf@P5(FJLs$]5mR&-o=u%VsWID>.Vv#xsqK(u&+3Ct.X8&Y[0W$SeP,3`?BKD*H1d2Q67HDptT-3/6dr%QbE9%CrgB%b[nV8pTk9<M+=x>:Z@&,U69<-g>cn%VCgsH9`?_u^I2H)JwET%S#IT%UB9:%XWgoi'S7MN?_'jCPO4v-36gb*6>Q<-]Vc%&Wv)4s4ktuHfp45TGrh;-w.;N<[eTbA,f@W-F('d6GJrl-ClYY^wR'$IPSbA#MPJ&#iq-.t97(p7=,<IdXjvwHjb3&B)pGp79qF&#d^x8.*n]%b(B,W-$NbT'lS:u$o9OA#NVpeG[-]f$('PA#T3IdbP?%u6_'eDO3Fj?#=,2'#`=8T%c[es$'jGT%%J3T%,D(P2Ngma3pQlr/nJg&,kFw8%4s;F=VYgF.f>#[Pn;*@#d:+.)k'&t'0'Gp'@=8)aigoW$Q4*p/A'vx4P_P:&]k;m/I>31%(m5(/?v')?x1^:^AR4s%/n35/M8IF#<B/Q%_L5l0uT^:/jBFA#a&SF4o2WE'U/;9.9]vG*_q30P+0QW2t7oL(ma/fF--0O&%X4))XjkJ)I19d2AM%lEl@j6Ep,97;`S39/E-KjM+xmXlK^)dExn;R*qRZbHg,&:/W####.Sl##A_fX#/On@@nwLS.S8(W-,fD`%8G?9%iT)U0EjX?6AQ>s-F;d]MWjg_MF*vhLFcAGM[*pwu@$8P#(g^C-'8f^$,2%#>cb0^#YV#<-Qcn]-t`*&Bl*8gFbEW$#dpB'#NdeM(W?_)3-5^+4FE#w-[5MG)7TID*X>buPtX2u7*^K41V5do/o>c8%KQM`$rYND>?s2uL+'*aK;b9jC.)[dDFDq<146A=%Kc,d$]f7T&oFtV&`o+B]j>3vQK?j&HSjsn8pWjv6XN(02fW/_S+oRr88#vcE%GPS.f^5c*k,h-%4x3m&TwHDEmPjmfMc*T@LR%a+1qS/)NKN>&U;JB#B4;Zus>g:`.T7$5)/K;-JYFo$DBG`a)9li'ZY[`*Y.Db*tMCt-'w_c@iM1AlI>)i'iR3m&sZ2e&^p,n&9.egLj#AHD99jeGeKXm'jHEM0RCh$$fX_[,BB(E#Ze75/54+g$)0g;-8ZLp2lTZv#DRIfNhRJ]$o^.H)#&m'&hN^:%U1,B#@YUlLG@,gLT[9A$)@5gLQD*^4DW4?--wTp9IH:E#]/4&#e,>>#>BNZ6VE/[#^^VI&8)9f3,_/$0SZeF4a^D.3INqh$6qU>?eGo/1Rq@.*=@[s$,c?X-N?p`&2/'N2]jhG)=,P',f_q329Grc%L97W$Fq3t$Ke]Z$;wCJ)^P*T%`R%W$C]/E#'n'n&G_GE*e3-q&I>dF<0qc;/E,g6(uccF%lV1T%+P(Z#HXnP)T?g5/`SW**jA'%MWNvu#SVQ9.*Ter6jV:K)t+`^#Ca#Q/lnGl1:7%s$;8;-*&_<c4<Rk.)en'm907=j0^.5N'xEjW$6qun&D6greLGh/)>>8;MwToS%(DB58%l3&'q&g*%^L`<->@dP(9_6.MOPfm0V_tPA'HU^uLjIT%^J3T%2isPA^ZHJVDd=m'?vvD-;h,w$tL3N0O[lm'&%1x5O.Hf*KdgW-l[&f?dialAF@;Z@#X+j*X'`gLpaLL3ICT_4wuUE%E`^G7)-OBO8tJfLTe-##Zw>V#]A)4#8sgo.YMMv>-Q#w-gc``3F)2HEASjv6Kf^I*1X+na&I'1X3F@6/mpvD*#?JIM/D2#$KD,G4ggWZ#dFnf;u?hY$L$S@#oVg*%[Md_FN61>$7Fsl&W][L($vbBO7u$s$pu>j#:,-(&1jb`%@$eg)):.t-fInS%wNBW$v10+*YS%p&e<o>#^-A/1]U2m/sio>,a8?r%bY%-)m?=t$]:eC@[b6lLTkUC,W7(5%s^ei9v/,d3pZ]?M%8>k--;Koi$GrB##@.lLp;_B#o4;Zu8-eT.t75$,l&o12W&?;%ordr%T$F9%>+/n&TDDW$Y(sw&5vgW$jdPo9&fQT.Hw<=$PdlN'Zp6R*lY*]$*####wo=:vf.hB#%Xs)#$2QA#@=@8%<Z'W$ekvr-dC5872nL+*s<RF4h:AC#Jj:9/S02e&^T&],:7%s$x'()7k-vG*_Jr3(ARbs%ZTXp%,x;Z#`v96&?a39'(Yk'.E>0p7W*eP+8mO,i([A[-o)/71'DiY$bPMs%Rsu3'hDD8&G4on9J3Ns%fh<W8YU$lLJ;e,*hFVC,elqB#HU&H*@[JwoXq@+%W5]SDt_mL-VO`X-&#`w0Hc``3as@v5v_8]$F@'-%4^I`$,na8%n<fS/5d1n&HYLB><4V?#d]alAx^&n/Z/.b#rVRw#O+H&4kB%a+K%Ja+iXXq&f34kO?JZ=l4s1GVlw5kOHr/l'X/Of-#)mb%u0]?TTT`LLR32oA=f'W/g3YD#TZLD3%&AA4iMBB%cq%c5ReeP)jbaaEBMl-$D3qR)#HfZ5/Aw8%Q?m]4[N(k'gf1?#meK5S+q*q.=VY8.I&XT@=G.a+N@nM0(jN9%%p.<.4BBP8R/72L7E360Ue$##@xqhPxAqB#+(Y;.Z2#d31mK)46BBG.%:*Q/Oi@T.>U^:/4'9mV9RFI%NIoa3NW.f3p,-a3eoa,=-hd[.mJS2L;,p7.;J4gL`cbjLT>F[$URRE<h:7LSeoDp/Qk$w$YfY=lhrDwK:ap(<%Ibr?ES4GDGf98.e)Gs-BGKp7j1T;.Oe7>g?kTP']Kwb4=W9K-g.Pp7Y36Z$h@Xt(w9uD#Hu(H*Wj:9/%Fo8%Vm*H*RtLI3v&2.2J&w>%,<D?>=j7?5;t-b4XTR60+`VN9,>.n&h<CwKE-_9&cG$S)eLo9&av4Y'd7jw$oJ?I2^db#'[ru>#FGoY,Z).gLDMuY#auIJLfQ8w#*>cY#Kan@%P*[Kuf)qp%.L5s-<0)-MWS8`$7OVc>'x,Z$Bma_4Ube12>BwH-dB#n&E+fN43BDo&_a]>-Y2vM0guC`aNA<A+]C8RJ`7H%/R@Df'#nb6&@JVN'OJB]Vf]<9%q9vx4HvfI_4FCB#1=E6J?cw9)NPUV$9DH%b@a?B,,)r%4N%+g?bY=a$tP)X%_J))3o]>)4t3S#Pf']s&i_gi#s(ZJQ3dUc%O9^m&oGg;-%d><-/ek_0%vF:vrchR#[;_hL9xH+#WkP]4KSr[G%R'N(EcpNO4)]L(XEW@,Hnr?#On)b*qZSW-[34HX$V@C#u'*W-RvOd$lY_:%FCIs*B-(q.Z8Z;%^Qj-$xYB)5C_39%:,_)NNq<O#X;Mo&wWlB$#t-iLb?UA$h^J<$=I?nANSka$N$1H)(i@m/<ofv%T^^6&nQuHOQGac#wY371Q3'q%%57GV$X*R28*WrQYh%=HZ67m0PPh^@b=2,`t[uWQfBXjNO>io-[l-ImxIPN%=r(?#dbpLmH&pXubWp8.WWt&#XjAa*g9k<-*FKX+AZ0<-':H%(2JDq7b7jV7UkoV7NwiJ2*xZ`%oqLs%*S>s-X:4gLC3>cM58H5&EIoPhmHec$wc&V-(,(lLI7-##R94<-%QrS-Y'x_)gs&wYHC0oQE#mIY-:-##,;C'OR6<#4%vF:va^4Q#85=&#@>N)#x,>>#9+H]%fsJS8jl1E4V6xI*i[rX-`C,cGfo+G4NKO]FZCZ;%@idX-qXh+c^LJw>IH:;&mJlq.V@%[#KB5n&0Cg9&#+P2(WjPn&oW3K(c1Ua*dF_^4Cdmd2U1^,3Z7.s$Q<4X$r%oV6,UZV@kxKp&sl(jr1[_%OFa8%#'b?T-&;sP-^-RZ,E@L+*MS'L&3=Es-1QiBQ[iF#-fjG&,J=NU.Y:HT%3gP,%(&gf`W-Ucs=_Rp7=-R#67fMR8qN,qrH####%qfx=6AXm')%_l8U3+OB&Q-C#x,$E3?DXI)jG:u$,r_P/f3si0>x;9/:Dw[6#=[x6tU>c42Pr_,PnSN'ep=4M'gT_,hVnH)UZUD-q'n:.C%.<$L3pm&jTJN0??YG2OwFX$x1&(4ZdYN'qO5(+?-9wGj'12qZg$GZTm'B#Q+v>%9u9/)2u4I)18Oi(b%G;-l;ffh8dge;Rg3_5A@e>QO2L*#>[fv$rZH;^b]oF4[Pl@MHmkj11lsx$<D,G4;^A*[&-U:%sNWh#D(H03mPPA#]q.[#`&+hc[2dNbk$J@#dV.kXGenx,C1@W$%G#O2#?0V.?;A'fkR[<$c*3:.n&A;-bKS@#7MnguDi1Q'8&,huoRAs5>_/n/:VffLtbm/(Ve]2'iu7P'dLhWhN7QG*PA_,+um4X$%/5##>WU7#6ZL7#/xG9i$v1T.1n9u$DPt-Z1>2=.Vq'E#I>WD#+mE.3A^#L4t'Tu.MD>n&>V:<-*bhr&g`d_#iwvp.i?#3'jDt$Mm^2E4Y_+h($W.B0klNaaWD7L(>wR)?q-q=9oh*iC7AZ,*>RNkFHA,%,Yv1O'0JRN'h=G$,XOF4N6dA.,<Ga+M`8_6&SKG8.vx7L($YRT.Y>$(#q)#@&2grk'W#:u$a1[s$O`sfLv<<9/jHSP/J5ZA#)w[a$ttr?#eW^:/vu/+*/0.a39i;6&`w,j'qAH@$',q3Cc@uV-<leq.Pq(0CFY/u(Jeu3;%*AF#YTF+5LuubN%2lgMsGq6&Q7^q2P('+#S(Ba<?t3xu$T)W#QaR%##J<j1o:gF4iT&],:@i?#D+p_4/e5N'19o495=k8E^_iv##&IxQ@DIW$Y5?[79@>0E%#>/(,<9K4efV[#+gUP0af3eFc-w##^Wt&#3NAX-m_dd$KXGd&?ZH#>Jm(I3nXQ@)hGq?'KQNHD)/K;-fVQk*%%?;-#qP-),iem&qqbgLUXB=%mp'H2EoYY#q>>g$ML187iH%##8_Aj08/^<%kj'u$&C&s$cZ`2%L`E<%PEZd3r3NZ6:]d8/$%*<6gr*V/;va.3XKwb4aIcI)&sMF3H*u(3Pb>d3Fg:4'YeCv%;A<B4M4ua*lANE4d5qq%^e$8':P8$5fkr=-&&).2UrJ-)?$u>8nL3h(WQ7>6,x`a4Pe4n&HtZ1Mwe[D,s5)4'Xavl1X80:)riB2)R5am1*(0W(l(<:gI:w[-mi:O(G1R8%`M.)*wc``3sI@#'p;la%g?Bj'KAl<'8MTgL&Fg0'x/$EP=FL584dA,3:dPp.b>'32'r2xnUY<:M%02F=9xB^#`[[oIqU=J*OCr?#*f@C#a%NT/F.@x6Z&PA#^hi?#&6mj0a]B.*[Z*G40MsO'FN4W-R&)C&$s[I)*)TF4ZM)h'rIBp78rFs6%sR[#1c'j(ogTM')`xfLC_39%.CYb%A+ou.['aT+dSvO:S.Y@$M)B88lTZ#%;hg2'VQOp%&':R&9XL[,ZrTS.&Pki(VQ49%t:1<-ou29)'uO`4=*<U:7B]_+VG?%-ITv70BX8v$Q]8@R^aq,3^ki?#Yq)Z6W_d5/*EY=7?@*c%4^ZW%%6MG)v<_hLU`1E3J29f3W2-;HYSZPJlosd2sfM^40qRp&l?6tL[]NUMPmbTBLMaL%_bix&$B5b@'CaZ#2Jvb%OS.n&cRTU)^M9GNE#Qt;wYc##%)###1^-/LXhwI3`-%##$tB:%t4Iv$p5g<$_TIg)E(-xLZ=jI3fl&gL&ZOF3V52#$57_F*ZS`)3pGUv-.j8`#]NWe3QbIP%f-E98'xax-.*4>-,sr200IRt-GPZ98*^:9%hR:-4Ym(k'gS%c3b3xs$@M$<.`NN'/j4@o/&*k-$t+`r.holhLoWfs$C&)q/fAOj9S9BeX[?W$#0?WD>P6w5/7,m]#tcMD3O59f3Z2Cv-^G.)*C35N'%fn$$W?ng)Lov[-mf+`>95'kLLdYj'Up:K(Z,CEFT?.q/F/YL:Mp(0(8JWfLlni0*L-5/(8?)(vew%g';:@W$JgE)+SQ^6&wSDK(lO3t$=C<p%l,$&4[Obq)q3n0#ah+/(KLb.q1,ED*^[[A5Tv0b%e:jXJ=[%WA.sT#$2ocCHfS&J3+`OF3?irS%AsGA#>iC%6tl0n%j,CoITtIW$hIc>#3vc7&i?Fc2&/s#5g+IM0^Sa1B?.PS7uqbgLkrv/(.E`G#(38Yumr10(xsF3b$wA@Mk@]H)CG###R3n0#$=*L#vLb&#rxMd%stB:%_Y?C#[%'f)l4K+*x3vr-Z?85/OJ,G41UZd3*G[%-1_lI)QNv)44Ux[#`lrZuU8v$cV^1O'OONT%n%;?#]b%@#3o]h(jngF*=#:$G)AfWQsG)w$S)X]%7RlE*Xgp6&aC,n&cK50(nCKf)Ojg40)I^i+O4s@Gnr,eQw.xfLnc(^#2X_pLkaW$#aO>+#kkP]4Hh'E#)?#0N92:Z-ss1h(1cm5/,X8[#nh^F*UuOv,uB7w^DcK+*lx3V/3&>c47qQd3jtuM(ZD3+0.Dsu5A?(E#H;o^$Fe75/$kn=%M9ST&ZWDigSQ^6&b>4##6iE0(BAhr&he,r%BX39%Fts5&RK^6&Bn/Q&kl*I)HJC;&iorS&>w-o[Tvd`*#IXN'hi-s$Jerv#CYl-$^3D_#3/1<-*.cK/U6)1LBHb8.BIs;(.TQh#)Zwd)W*'q%81[8%wLCt%JEPN'NNYN'n&0I$E?4;&5ta@&T((c'q#^8%pg3#-;_P>Y3;###sO7<-vq6m%hx,AF^I1hLMYYA#1T6&4(tcf%CoWt(e?lD#L8dG*B.=Z6:]d8/5a5g);Vq]9:4RxkdD24'lXZe$QLAq%dUl3`lHx_)kA0K2T4p?LtWY>-xUkA#;RWNMixSfL]=T$.p9Ft;NSDs%]m5<-iR47/@[59%FCsJNkAPS7KORS%9DH%bu:#s-03k%=WRjZ6mU.>>/H&##jLB@%L$FW-x%,NF:K[L,9_B7J3*gG3A7^0%Me#'=kE@`&]&&*'m+Ep.7%SN'D($Y0:-Dr&H&F>H,+B+EiH&+.=,]H)c_o:dSQ^6&Ef>SRp)l?-9Hg;-9r9s.0-/n&q<.S*>Oc&#T.=GMj]xK#@Oc##_qbf(Hpi]$QUcI)bf4O%Eff`*VhAW-rsL0ESV5Z0EjX?6kE9QAavl3'%H^e$t$(-)Y8`oC4whr?ejrP0,l<n/.aDL'rJ,$G$m.T%Zf/6Ad5qq%0bx##(DluuW-Zr#$`V4#R'+&#)WH(#Cb5A4od=<-Y(co$;Q:u$`S6C#ZktD#vt@T%VQ,G4pxJ+*hWTM'5P[]4CIFg1,I_Y,<RIw#:hW&7&&rI;Yb3.+nCV,+lciO'f$+T%1am<29Vgb*qMUu$E,jI)Ha*L)fw$],E3oh(G&%r%fXpb*x/;?/8LZ(+6^ATAISF[$[u*M(<C??,#fLd4]Uh<-(pqY$Vu<8&?fg'+7G3^4#&k^4+;=M(]@g;MgrV7#'R-iLx7),).gY7%0gt?#*e75/wHeF4*eHd)T$Y%$1awip$h[d'5pp#*5$;M(?qhtaqv0XV@ZXs$IN@l'C&SHDY-8='JT@b*.n>b#lk7Yuw?CC8#lhl/*&>uuW4>>#/EvT1ld0'#(?$(#8pm(#KaS%@6S]F-C=(D.x<7f3[(a5/(0Z&4?Dt/M@9.$$``Ca4nE'Y$D^jD#Gm%1Cjt9RDgd'R)m[C1Cdv#O*#89sCWq(@>wJ,W-Z$&+%,_$/&vNT7&DBHa3D0h)3v4a1++SN1+]6/W$-Q,cE,In59[<I60V`K._+FnqT7fiQ9,u''##mS=ump%_]*i##,[x->>Qt+M;IrY,*Bt`+lJ[=j16HSP/ZI(eZV7#`44,p/3L;]n$$,h.*B.i?#O$/F.7MbI)_2qB#^s'hl;)C9r9)TF4QNNjLXNTN*O>gq%EGjg(-v-n&f'Zu%E[9t%PhZ(%ad+'&i6kt$bZ=9%-J8.,;v`g(L3bP&Px1w#g79&(9^NoAE2Bu&EI0H)^$-7&rRqs-NJ&I&KSM(=39'n/npg#.SN7d),@g,;4#Tq'`Bxs$gx=?,.r%-+Yj/BFL&3&+ZljA+7/Co0-?cT%<f`Q&9%BQ&[vc01OB0u$1>cuu$8YY#Q*[0#FVs)#*n@-#mp@.*,x>m03^(l-?]<X]JopcNaMOZ6^H'>.sw>L/xx[]4x(dlLDZYA#BauS/Pf_l/7m7Z5F%8&4x.3T%xGSF4nGUv-[YWI)*>ND#&iv8%6C3p%qre-)q(J-)X##+%3Fc**I17s$n%f;6kRl_+L9N*.#SiZukh,##dG.P'Y>l@5C'0Q&U(1s-e$8@#N^[h(bYR1(nIs9)p65/(SmGr%Fvfe*6lJ-)x*?h>nr24'_GnI2ulWa*ln9n'+C36/](o*3/K7L(.O1v#^_-X--K*R1#5'F*9oUv#&&###hLfQ*0r7(#I]&*#=sgo.IR@p7;eYD4pf4a*S+D<-(fq-4'Z#t$7MN=(-tx>*2O_Xq5KA&,,kJj0j,24'$xPR&ptdYuT<+.)1PwC#Ub<5&cc>w#qL3=(@<]8.L9r/)/XDI0_@9K2bPQ>>$8E'oNE8a+taJV/FV<Z8F/96]YNo^fJ^8xtjvUcMki(,2T$t,*kiic)=>dp.o]d8/CtSI$LY)C&gS))3pM.)*V5+KMIqYF#nh(k'->=p%Ixmp%3@Fx'S<G(-AH0E<[URs$Oc:s$K*EAFH6Gj'O`im&M5xW&:1gX%%<Ld2g:os?]=2W'_wH,$J^XVHO+O9@Y11hPq41L&r2w%+F7$##b1e8.;JjD#Ktt20YAOZ6rKdG*1/2(&9N9@Mbi/F68SBj_wp))3#X'+%F?Bs1LH]X->:@m/O@ul0ZQXn2iod/:Eo;Q/guC`a5Ljl&^b-5/[;t+;sg%##i5``3NsC:%^wn8%#q<c4&p;F3xt.T.)$fF4IJ.^0HYMT/Zc7C#dI+gL)Oj?#a^D.3JU@lL5R(E4iSp.*D.Y)4^FP.)=MiR^/l-s$X8)o&bK`C$]qjT%WwZqNpEGT%6aJ>,E+Mv#VR.s$x02@,lK>N'ZJ'Q(,K?7&>p[@%f]<9%<D[m0i_nL(U@Tl'ROx[>e>mj'3AG>#PP,%&8x`C&j2KU.'e#R&-co_4X0X6/:mxM)e%Ns%u=%6&ZugYu0N%@#Ppe,MLNj$#S>c^?_0-w-laA7/GMrB#*=Z;%1Rmv$?l0x5V0q4.]<7.M<n'E#VF;8.InB40(e-)*L*+p%'*Ke$wU[[#S'o8%VNF5&m)w`*>Q-d)`(89&Ob)v#+1i_?o&k%vYJ`-,c[np%o:2SA:R5#YOUDw&O`mp%0*%<$^`h%%(KgppaKj$#(qC>RYQ^C4EoLm'RUO*e:sj;%NY:xMn%e12M.OF0rCw8%vC-p.)tf*%7pR;6T_^v-NB==$X5NVp[:d6%&4^E#+f<t$lU+C&W6EW-FP5W-;kj']X+T8@ZJ)<%U1lr-f$fa40k'u$rf_:8.<Z;%vV:X-`+/hct`J>,L+b(4u?lD#LooA$f(;k'&XdN%f]<9%MJE/Or,Hr/GQkV$4+@W$Of(?#kcR1(Qd<p[HX:X6^dOgLUrgE@WtH_uFO@_#KOx:d;:@W$p[/Q&.X?]OJgm##>*q@1Q,>>#oDsI36N.)*0Yw/($9Qv$a&SF4ca<+N&t>g)irQ2iicSC8Z$s-ET,HS/g@oW%o>mW%EqHM9absPBa&8db-LZ$,V5do/aT-I-14n-$NSKX@D)jW%b0EM0K#5D<+jMWA@$NJ:)Fgv->;gF4:&55(pv@+49n/I$c?RF4O;em0m+B+4Ia6.$>IHg)YflS.U,_oI1?U)0AYKq%n8qq%5vY=&obmV7e5X+3ZXR[#BS,)Oa2YX$7Yv5&>p[^uKsW9%Ym5R&Hxi/873L[0C*oB/'>g&OgpX>-_%as'x]P&#:>N)#)nJ@)tB7f3'>:8.x5MG)7#K+*`R6Z,q:Bf3V-vgLGF^_4+7Z;%sUjAdNQ/W7x^e&,&6KV.cr`8&ei[H)dv#;%7pW=&i`S^+lYaa*0*5W8HmE`u&&js$<(0$5`?Ss$1n^u$;&^M)Z8Do&aNs@&F+=',^PKB+&_gZH>_tk%#PMT.Eke%#+wdU&,ov<-4$R$<^XXKlHLr)5,@i*8KK0?d9^a^4a?/A&1S>s-qN888G%)d*ap0q.3WgQ&+Zgb.3736/,tC0(]1p8'A?:D3v^YlAv:38/xC^+4ckPcMN17<.[7%s$nM.)*%MfI2t?(E#m$8>-fqR:.xUKF*8MYGMTE`hLw<]s$YtTw0i^1*#M=]S)w.%q/;RI@#k%ko7je8E#_uvC#kkoA$>Gg;-OgGhL5ZKT8v$%Nq?P1v#DV=jLYvrc)eR/a#hLjD#-2kT#jVxV%6F9/D1(cA#PkY&#5IthU-RF6'SVW]+l<IP/,8MT.GlE<%GTXA^(`*w$YJ=c4ei1a4PGHb%R=]4VlX,Y)T$HM(%dm(5;$bD+OHe$,F;)=-KD$$>p/D)+vedfVxRM&5HPCi,U^i'#$),##H5[S#'h46#X?#h1na&],[YVO':]d8/^J8c=]k%SqO8x/3>U^:/Q4xC#^)-'=/OR]81AZcDOZeh(YI%xS(aul(-dhN'm9Xh>W'-BQ'e%r)Q/`K(W_uNB2gxkEwmT9(+MuNFY,Guu6N_n#Bv$8#:,>>#$V`v#a9h'>4h%?5D@=<%)c7C#EwWI'3C>b#Uwca7BM^9$fulXlU%B2'Ox7K(7j/Y&a$,i;H2Z'=UEf8%V``w$#fsH?YrQS%;RU%tWHno.Ab]w'.lh8.9t1=/MPsD##7'l:Fu[4;;kkD#X5ZA#C@ILMW^DU%,t@=%luF;Dt*4?#Oj_,)v2X2MRO$N:E0>T%%U]p%dF<4:nkgv$9BET'UdPN'](.s$VAI2RNO_hL@haV$h%`pENG/H)%]w`&T+@79=Nov#DLaC&]67HDsuQx-xjJ]=kK?/;M3Q:RGTG)4M+CO(]fMw'1jic)(g'hLKk@`a]kjp%RA>I$O.A`&F7lA#5tq]7,'?'A,KjV7u0<^O7F/j-<#OZSB8xiL$fXI)gBwmA;8<Z6:]d8/L`d8.J2:9%:MpPA&LT?-ew,?8%%;?#?I0g-45W0Y;(BoMu6t@Aewx##I/]j%deZi99g&##XEW@,$0[_;(<5b@Eff`*xlpmAeAM3r@Vd8/txgG3d5=k%Golw9[;_ZP+V#_$#IwYMj`>4M`hYOM.k-AOTg7o[O@rn*Z/dofgSdofL9DC&qnd;-<1v<-X^@fM#*+RO`)pU.$,>>#Z8`=%l=$##<WZ[$GD,c4@<Tv-<)'J3ubx:/uTER*nf)T/[sB:%'1clAbGNf<3'2L+IxCT.Cm=iC+xc<-k%BgL]2eTMh)C6&XgGb%P?%<&cY=kL9KihLf&E*'x'GC7/LVs-g`Af3a,MT9%PRv$k)_:%?;Rv$@7;X-WM@['p&SF46:[9KZ,E8*&enY#OS^F*`rH[->#dG*KE@[';-ekER[w,(iwa9%L@Yn*=F1dM5:2=-4eBM;.f8a#:WL7#Y3=&#$?$(#DJa)#t,>>#lLbI)_i&f)>&Yj)$8b.3.V&E#@mqB#(LT:/26MG)E]JD*:q'E#0VtT@gLM-*`M.)**e75/CMN:I,(G3barg._+4x8%nMnGZF3TS1#6.H)qd,i;`DDo&:t6c*uNgq%U?BU%#ZY8.4fXw53Iq^u`t$;%e'Nm/&:Bq%QnuB8v#2K(JW+>J'=/k(^VA^+>]5c*LC,w.,)ag(n2t-$$p#:;G3.iLc3)A.6]v7/:CE&57:^?.&>uu#[:rs-JdsjLlW;i/EI3Q/jYMT/*:Qv$?fh*%]1#`4amd)*mt'E#f/s0,]'*?#d,;mQTsaK+h/)T/[dr3;e[@<.^+r7/ohQ^,88%s.J:/dsQJrb,qL4T%CMt[5oti1)acC$-o%.#>?vXg3Zcun(U/Le;3=k@$L`?Y@0J###@NoV$3>jOKU3Wm/?H4.#p.e0#Jk>3#%Qo5#v0tD#vu.l'p;Tv-Y@u)4;[#;/1Hjh)GI)=-3(Qo$c-YD#%<3d&2cC26[Wt/6^DWp^1xYT%b:.w#9M-t$J#3Q&6MjP&o:x`*+`2@PonF,kBS3;?dFsq823rZ%XpT2'Q=r;.rC[<$?rl29Rk=vc9cK/&Xev)NnZACS2NgL:J6@'lr%.GVJMSY,>:KV6kC[3D`Zbg$'*p*%-6TrK:hkD#StN^,l9/$7x>^;.1Pr_,<2B.*D.Y)4)QO1)LET@#4h69%siuYuDg#nAKUaJ1Q-92'U[`?#%kAF*x(3=(*o-$&*bYIq5v9[0iV3E#qlB=%e,l>'/B;C'-9G01&r3t.n0MA5A<d31(7*KVRtH9I1Hf'/<#.GVtxxj-g/vq9Ved##NAYHN@(B.*Bi@6/BkY)4Rp0g*%M.<-k$b30+gB.*chq2)G.[-HW?X-;ovU1;U$%e-2AEU)90,pA)9rBPZ8Z;%4`,Y@U],[&;S^ZR*E;$B8@Y&#.*h<LB`/E#cG.%#d^''#>DW)#rF7D?Spl)4nb+`#$17e-YTm%RN+QDObg#9SwE?I3QZoA,nO*`#*>G$,v9`H*/Ijm/6^K3(@e4n&*EV?#6Np;-vRggL0oS+M6[t.LXOoUd6emG*LdPN'B:MZu#/R$tK9^m&.P%pAl/xq/pO+q&&8Yuu[-Zr#UG]5#_LXR--kN?3^nr?#AJ:?-aY?C#H=[x6-@QM95&,d3_w%>-xtu=6_uIPJZc.T&sQD+iuf$t-jMxCmdh[u.OY;B#BwIu-%O4jMHg*W#3%:-M7lS9C@dOQ'@t;D5cda$0quAuI>?b7/NpwF41Q*jLEQ-+#s%8d2Q6F`aQiou,<@,87'n>PAC<CdFEgN1)w4Kt?%.2m;l3Lq@;.g;K6a&;Q.+1/)KMYe$PsKW$:h.ZPV7ugPQN3$P28YCjQ6dA#WNmA#&90C-r:0C-nd,`-EQ+r;Z;H(&feg;)XsIb7#]tA#rs4C&xRX&#^Xd8`scc&#Zs*VJENYD4s4ck%7ZWI)pxJ+*$DXI)Ag<H*BS7C#W=[x6/8d8/X`WO'[&eD'V6JZ6F4p$5JNVk'0f:?#j5u&rL'bp%P^V_XJ4+X(rNh('_iF7'li*.)QYVZ>:lig*@7<5&g[^`NPQ]R0Vp(O'&VZa+h_4X?]GDdaQ7FD*]`[`*0PNK:LF[b4sJ))3GG(v#V4i?#BKc8/ri#j&5Y79%fkn9%>-h(*f-W@#]*>F)gMb03j,59%gp$-)Ob%[uoklbun;)D+BSV<-:<@u%EnK(G&Fv;%0E3jLZlfF4abL+*r*UfLg6lj1u:Rv$lsOA#s9uD#fE5T%D<#Z#N:7w#DTlN'9#2T/VN/E+Ks?)*,M(v#`f<I)0QeG=)]V?-&3g._QtgfQpof;$Psp>$.c_V$kgtG2Rd8e*P(U8.2oh;$6F*9%33TA=G02</#AJfL7hmi9RAn^5jK%##,R(f)b^Nb.3>XQ'lF?h-NZ[r^%=_F*w<7f3?E#6/:*YA#:I%K:GRT/)q#5@Mmg^n)Nl,##^?3O;h]rO'rQmK)dWkF5mwsl&mX.[#ObAm&lp34<?PhR;K)Wg(>:%<$q=e3DW,El)-;0F*k;g._BrQ)>EQGn&`#ai23o4o&rA(?'jQ9)3O0ZiEJGbY$B'0q%>jajLaVI1g?f'+*?`be)8+1GD88x*bQ+18.dR&E#s6Aj04k_a4GR6JCna#K)F5)c<8a%J3_KR9)ot3A-%mf45KDZ9%o(/H)Xf1+%hn/+,b*-p/tm?P1-e+-57=]>-^a%jLPo/gL;rJfLVqQuu;m6o#:WL7#c,_'#L[fI2(wX20KGM>$KD,G4=R]w'[@i?#</7T%DP=^4Z8fG#$C9Z7LjlN'@=I<$jm>4*LxTi<Rx^T7=IET%BDvs.t)9_OY?)#5V)ja#DUns$WXXY5.xY_+];9&4bjGN'iu3i(drUc+%?-w$[JIwKZdU`3W)Xf:#$&##^Mqv-?V6<.GTN/MTEZ)4u3YD#%2P,MF>B.*BxF)4)gB.*Z5>H3JMeC#k]>_/qcB.*ZNYXRqw@`aWkJU/<OqF*;+lgL#+6$,awV2MlO+I)V=DmL`Vii1<KqQ&Wf.cVnxV8&JQi.PU*'B-qv7d<i1KVMw?CJ)?SQX(YxOS7nFG$,D6eg)3ik&#%/5##$xg^#O*[0#m4n=HGxL*4O-YD#KnWq.gdeiLMW[x6E:H>#/7;Zu&O&n/j4s@$4BVcua^M2'?>>mLc0W?#U3v11-SKv#4DFbQKKoYG)Laf1#p=:v[PkA#BUl##2BN/M'0V:%fZX,2vx(u$d<7f3V&QA#-0ihL:?7@%G.<9/2,h.*Qts9%x@bW6c1eQkt/+M&X._guW$r>#gVYtA1u98I0#4HVn9Ac5nIU*8rs.P%MUeZT-^n<$/Yg%O$Oq%'kNmAORa^nJiLcS1>,B.*IcnF6aOZ`%AQg8.W#[]4+KbG3em.Z5'epq%ZTXp%pQ]p%xj%pAEBAK:)T<**X-&3Mfj#C-Ba9e;]pZIMa,CB#u>CsHDD6X1NhRg:b;q<1m'jmLfp,C-$lJfLt-gfLUhZY#:+[0#A@%%#A,>>#j2(T.+dfF4jR9k$[e_/);X^:/$aaI)QS1n<kxhha^904Lp$v3;YD]1;[Qnh2FvB0GdDRh#g=FU);_7>#q72a4SNvVfH@k,Po]_C%oj]e6lsQ]uB7A'.Ux[+M)FBJL2Kqx4U)t+;1gn+D.m+=%2]jj1pC,c4-7Aj069%J&#&Vv-F.@x6=J))35NCD3)dM''7$g8%a/`)3wW=Z-2MBdk:t'E#-+7x,T13QhbQV,D)S(KC`&PA#QbS1;Pup-4003n'm^va3*2X*4[iqI*;UG:&JeE9%Rw=ZGv8Yp%+0w8'88C[u>@n?$bY/t%C@'U%-GLW-;CP%;;'ev$Od?120kFK1<qf2'gH]J1fe./1Q(-.4-^R'AAk,;/Q0XN0exBf3`1UR'EbE9%[rAb*C8l>%h)pa%vFxtH#jMo&5E(:8S.V#0+`pd#qOO/29L2X:v+`3=uMKx,sw;;$][u2V.%S(#VC,+#eONn%*vU,;cpC(&/ijwA/2?X$@;gF44tFA#B(p6iNXE]-&[Qn*JL_$/ut0+*IAM.2%FXN'QE>N'Us14'$19ba1we5'-lfq)l^S$M(Po.)>A@I2DsH-)rCxFMZs5/(9[_B#w^Ta<BE6c&IATu@&.t>-ie1XM^Cww-'.uJ2&xf-6(CHr@GEH9M^;^;-I>;X-ggS&ZQO?>#^)V$#(4#Q:ZJvG*?,dNb4??j0n^?d)fG=c4Ze75/O_LB#@^r%,p]-6M.H'2-p%/v$=(2v#e2(?7BPDv#iE=n,qxrY$iUo+MFYxG=W?C,)+n,tLTRr$^`^Pu+At?g)dc4Z,E3Xx#@^8F4L_`;$5KB5SiibK&J&3>5klVb3C'pB&DFWAF'SK/)xTJ68^5M.3)VFb3Ql#r-f@79%rBGN'_DRf<;Vk2_gqD+5iAUHM8r<P*Ur(?#s)P]uV^FgLF$GE&TT.JM;k#u%:5$:57>D?#Jk*R/=sf@#[ou##43x-a)eA`aX%eu>j,KZ-N&B.*_02BmD%<9/aS2C&Lc7C#i?uD#R+OLsJxq_,t05GMGe*Q/>9`PiPhkD##jO%tK-[COnS$9.s/cA#p;ka(=X.x,@*9q%s]RN'R1Ub$>:wo%s2hN'#8H;H2>h2(K>MBoSuKs%n<]T%S`4j($[e9.<eH,*v:Bb*_@H>#wYRH);Nlu>UQp6&D@RW$>KNmf,_I6j((Nm/tfsC&q3n0#H)###f,eT-@7sd19OnA,p:Rv$C:H:7?pUSkOVJq&%>/X%)^dI%Gdc2L_YF<6RS(E%8c:J:7Hn2Lw05;6a-YEeBQCD3VT'T.HIYQ'meMI.*H)w$DtJm/KG>c4;lm=7G-5[$gYoGM=xcG*oIQp.-)b.3$pvC#7NQ51SQ^6&CjMH2N[@:.*Ks@??fo/16QbN9ss4O0<K<T'+<UN'X9GO0G(;Zu2We5&b*p$.up10(;GUG+*8=M(nqWN0mPX9';$/$PDD'0MxK@0)%L/X$[1cM?t7?5/3xH]%'I'Ab6M7A4_1IY>*)YlDi`r]$kWK$6P-g:/OJ,G401mo7xfG,*OKFs-sw4gLnPs?#L2JD*ZYPs-FL.lLtAng)]U(f)h=%'MI>a.3IO'TRsn+D#S:&E+8qU<)D*3)+t(AZ5u_uT'fmP7&xIG$,f.B^+uqUm(t=%w#w0O+3xT#f*)l:e347aV$F'pM'S@;Z#WYx>,)XM#PnE,N1(fk.)pSBm(?SCw,#sEI)7+Os%Bqa9%BC.W$7'D7'#+rW-CnK5oO'[ca4m&9]:O*t$:r:v#M.7s$Q[Rs$ROIs$x(^r-P-m&mBB_*#,s=x8>*m,*Cid8/64LT/a%K+*X+(5%R>Ua4#cx:/bwPl$`J))3pe2J'KwJr80SgJ)fUwG*:t*<oZW2E4*)vP9F$?g)vIDn<f3R>#EgBG;[rBR1jfVo&>0g6&ItD61QkI>#r@G.)Be:&5SQ^6&ZvHPT4gYp%<D#V'n4<<%I*_q)9E/g)M8Co/D@xN'`Qf8%N+AC#j+vw-U1RR9hde,;kr2x-oU-##%b$M;4UD%6B0^30,0mj']*JI4LhR>#eu.P'nT8n/dNl/(f3E6/n?^6&=2&_4+N[f)>k>F#fa:L;vM(&=AUwS%sHIE=WXtJ2R,U'#Q5b;6<G?`adhLS.d9%##'Bic)0Zc8/OM>c4tf`O'9mE$S]<p:/+dfF41tB:%2$Bp.Rp;+3H0$$.Vf-]-^u*O4:MlxFuoY>hR9OZ%FcC(,W4Qd67JHI4t'Tu.5gu$,%[s6/qh(%,d224'O>[tHLldo/-g5',kL7<$b8[-)2Z'Z-m5-;%?lv&M3w2E44h#nAdEFT%lnD<'Atoc2CJ###$&5uu^>tY#(*52'+F?']H1^=%&Y@C#'BshLcxV[,vl1T/&Cs?#HF#<.kK(E#=rgA4X]OS7dBC0%L$EHA=GjG)r34?$ZwLiLB*)i2&+O=$(Ck>$4J.EFT,HS/[IiD1OCuf_R+op%k4HgD?Qlp%q=46&0f$%/<55',T$p&G78'?-;1UV-Q=#B#Zr/Tr:`7C#Jva.3@/H9%WwM;7;E-n&S&bjL3HfT.ap8]Iu90:8pHCE#kLlX&x0vhL:6)V&5v4)>1+Vk+ht7hGG/5##(7$C#%,[0#[9F&#tYTC,lHI/2PeUS'*T&J3:=h@%wN4#'DvY'=FiK<0Vi[<.:VIs$_t`q;0BL$'087W$'e0Q0R#TWIE>)S(Ll?%b`6;(#%)###Z<D;-v'pu5gB%##9[:4.*pXjLkRU%6.bL+*e/ob46B@^$)J+gLE,@U6.DH5/61[s$[rL;$S4iK*D@E5&Yi(?#UtDv#Vp5X$.UMT'/8op0#AE/2M#.-)j`rk'MIIW$#Y)Z#u$`<h^+ws-$shu7/c#QUt2E.3/Vqs7X0kDYqUcT'4W_s8'Lo+/*P+q&%kNh#/n7T&xt/v7<0M&l5;U`<jA;%U,iGqT(c@C#[HSP/MB-a<qO`H*[5ZA#a&ID*nQ#O-1wHq$d;<@-D;J1(elf#,[]*.)w-C-Msh)K([0OT%ev6H)B2%>8cd/Zha?*$6M[l2(M4+O4nVSv$lWe3FBoWX(*2b**j'H9@oGBZ-N]du>',GQ:^'19&K[vU77jvU7)oc8/5kGA[;;Uv-3C.q._R(f))dWd=mSpS8?36%-uuNE*pK$123#wR&#;L@6n1l&H*hlh8GQA=%3[vc*15_e*%x+&>6?@+#+bA9.^?O&#6bD^Q323ae._`>&4D#k2Jpk;.BS7C#VhnJ)P#Lp.PV&K20gYKlvO%Q/6SQ9%sMHe2UH9Q/pUIs$3v*32O=,B#kpK)NqN5v.Y1vV-T0XR/w2>x#tNeA,M?VB#DS%`$oD-I2u>>T.$R>j'o6-a$MpBW$q&*x-?*-j'wCN/2YZ0r.%aL#$e>ojL5'wu#9DH%b'_A`a<wv.:c&al86lSU`142eM4lC)3$'8vnolqe;Ud0^#8=q4.OGqs7n9rP0`D@M._AY/>a^4t-DwU%8?ZtkkQ9o=-1>'32>6]x,GW(1.8H-s8#=[>620_1&oS:NL%+ei02>X'm-i@C#gu.l'kSng<cM8f3kM6-+5e'E#MSX$%aN*97Ck3X$^TBq%YKOT%X+/%>Yc798TnLj(`r+?,S,rK(ZP$q.1Ww[%58?X1&6mr%pK*:.2we+>4Z6=.bK'U%%DYt(+*7b3'NkA#j._'#9kP]4vbLs-@J,G4=6))-=:,HMMI:u$c^p#A#x9+*mq<W-X*.eQhlvo/JFw8%,3%iL_4QY%p&Ts$/(XX(/1102HZ%12FqV/>7=fB,Rt@W$p5Ea*8T4C/E9eIMwxZr%0T%?6?]$##%####;@dV#Fk9'##sgo.O7%s$Ut;8.^WQl$vEo8%Q4@E4Di^F*J1F(=2BcD4)][Y1iCrp%2g8b**76$,FwaeHE]@['sH4X$Gs*J-8tVe.x)pn/a)p$M;EGO-D'V=1%&>uu&HbA#*6i$#-fT%%/SK3Dx?Q&%QwM;7Y,f#/ap8]IG/cj2C.xE3wF'''wG,*<;we+>V:hDNm4oiL,nd##Dqbf(>83/%/+6ZIcXE#.TxJoLIt5/(jjm`F&^F&>t4n0#`cT-QtlIfL;AW$#c0;8Aq5h#?-B&##vF?(FXt*B,e0e5/xA@m'+.`B#Ps)9'W_`?#<$`5/13vN'n#GOMOho%[)`>;-gPBX:xcK>?u5)i#FgJ;*xg'30fXL7#r&U'#_4SspO5g4,B%r?@.*k9`AeXD#OnO`#Wljp%n#Pg$m$kC&Ac3#+Shqq.D7u;-9,lC/YgjJ2F#Nq/?0<S0.+CJ)u9jfoS`Fo$N,J-Z9M'eZS:G-Z1'Ea*nE0q.[5ZA#+SXTW.6[q&]d^Q&@T_Q&*'YK12cO]uqS<M-8F:-NL#3#RJ?6##'4-_#%,[0#U&U'#w_Tj2i8vW%xAOZ6nf(LNTV_*<mJc)4=^,7g;P2Q/Na59%RiuYuo[dM&6>;9%6sGp.Pu0eaKW7p_[W49%ijO_&X<^G%mX.W-iA3L#`XI%#1a9RBXLVH*.39Z-Vq'E#xpKD&0&d<-^U$6%joA=<HkEv#T@53%H,=g3^XLea7ZWR'p_`A&@2M[-?)mA#U2QP/G0lP&G^NC5.EC_&@GmYDB*xP'tK=v-JFKfLKUQ##<o>.QiX,87F4[HRH4vr-[5MG)RJ))3e)gAIul+r*P'#TRM8th'ju+b$&R:<dJcR&,AEOh#W-P`ML/6O-F/;P-B3J*HL'Pw$ChlPNSed##AEEjLJ&7g)7,B+4qiB.*Vr$B&wM't:6bkD#q'(]$G?._#dBkA#T-P2(/7r13<-DJ)RF(%,%kHlfNp@;-:D]5Lr>2O'+<UN'at+',H>0%,]C1tL9/gfL/^e(.$Zr*gb:Z)4#u`2(._#G-,TDo-YEkmFeNO?TJ2uo7FeO&#?fvN-0sJv[G7)62$&###''nl8S1fc)l>,<.6KHT%7`d5/)$fF4W69u$J(3.5epBd2p;6&4Z;^F*PsYV%3TgF%Lnw[#`h/e?C=V?#DsNT%sg:E*98cHa<PZ%blQ%##bkh8.aHXXA#6ili@GUv-2;XQ'j6Im%Mtu-&W-6gLOnkD#vcMD36TID*OIo.*@f68%Wg_p&WcS`$M&nD*=f]h(_N..MD6F7/1YuY#bn#&OTjexO%Ok'G)/$$Gb(@W$Zx_v#kf[h(;_1ENioHx-*5xfL?_3S8uNbxuW#Ls-v(@V8pn]G3/pLs-v#L2:^APd3>uv9.7Yvh-]L^8MHTx>-*6K'&@aH&40NSj%Fw(B#QBcgLRasIL,e@p&<lG<-7:^gLk]e(':q[?#'mGV'Xkw'&YK$YO33P,OrU'*'%t0n&>?<0:&ICr&k@qP%;`/E#D(U'#ckP]4NVC)4@HDqp5BGO-%=7BO1AsI3uE97&Q5%&4YS2N0NCPS7jpSs$5.,gLlX>;-C%Zca.oO]un8t30Y#LT7SQ^6&&NU['dbck+f6k=1iLsV7*TDX-&Qv92BdD2:HhG&#)G330Nke%#q@Rv$EX;r7vHFm'FUI$Tu9J@#s:MZu`a_51x;UN'H%w5&8)2['bdh9MtM_6&`+6SBf$o5&9)Gda<G?`a=`WlAmc5g)nk-q$nUFb3vg;hLc?i8.83kn%/M0+*pGLp.P^r%,UH)p:WW-12>/pc>Z@b1BsvgS/uN)%,DO%(#&7ZZ$9JQ%b:Ze9D#<[`*9]R]4v0J3b3cLs-9p&+4GU@lLCM^I*p&PA#%5E<%H@%Y0@9x:.(e*G4rfpG3J0xgW5Et6/k>Xa*BKk87jAqB#BR.@#$,97;#rk.)81gH):=p/La^k._.3[)49nQZ$F-BQ&Eg^40*rk6(C_39%a6We$%f]W%Tv:T.4)=.+%Lav5Dme&GoLR[-*:U=6]t)D+%8-/*_WxKQ.XZg)BH/9&i4b**F0Su-bhHf:du.t%ZTXp%/mg30EuW>-&;%T.5Q=(j':*/1%&>uug5wK#dxK'#Z)?T%0<(u$b]e`*P,Jq.H^Rl1ttV<f88``31m@d)OnSN'`f0-4'G7F%$R<vMWN;a4TEPd2sxs`>0,ub'UdPN'Kw_h(af<C&=tZw'/e1J<ZC%q.HLGD>NYB4;^&+J-iON]0%*Qv$S,]+4ewOLUG4_2'&'N7'p;`g&awA3LoL3X.ea&v-MH=dXsRQh-4IFZ.k'L,3l5MG)=J,1MF;;GDwAQ40DkuN'fHnrfb0,</*N_6&1WF<QD:>)#vwVp7i]a7Ok4P<MH,^_J)'=##bovA7iDPA#f'Nm'C8D'oB4vr-gc``3:ur;-RDGS./;gF4Xv]G3(`If394IH'(-1H2CbE9%<)V0(:>LJ)?aJvP,/lxF/hhdM%d-s(Ke8Q&Ht<9%sYrH,la*%,6lA=%VT5W-PMUe$nrOJM*R)%,(?<C#7DQ%bR?b%b[w$##/uSkX,Jo+MddVe.Bo6x,Y1Po$$tFA#Pbfv6ROr_,=qh&OGtq1TOq[W$m`w1(gYBu$Osus-EBniL+uKb*.x_5/Lw*t$*b1hL(^p@#6kGR&W<;@G]HkT%hmT/)NUupoH]Dd*?9T'M_])w$trF,ikj5c*M3fS(<),##[*Zr#tXM4#h?$)*K/B+4nEZd3tTM`NQ$lj1FHuD#wgAI$7dav$g7+gLI'E[*'f0F*(6CW-@^r%,r6q)'B7wS%2e8:+ri,$GV,;O'Zx&a<w0vG*s>k-$hg4',:rsG)lG%1(K-1p&u<G^$@i)h'40niLLAc(Nn41E#?`''#<H7f3fWfs7O14kOD:n=7G->x'nKx[-@GO.)X4H>#+Vfx&2EUN'=Tga%Qw<x#5(o]*^=D?#D_Ku$3;nY61$i?%_fJ^+:E-E3u?mG*XaY3'@?H`*R5PkFet;##1gx+;5oXfCS`mHH>;gF4S)ZA#`q>C&.*YA#)v8+4/]<9/K(+^,=gc-2NY8a#iT&],HaLG)#XD.3kHr;?J]B.*MiGuu#/8#.UCw4(ppnL(2w?s&xMnL(p'I5/g86E3TmBU%%N)#57(MZ#hZUK(G6Gj'_8m;%KH'#$p+0F*4LnXlCi/l'cH7L(Re080<+Ns$Rk5Z%&`7T%DGNl$X)$V%rQik%PYMN'N;/^+7eaS%o22h(PuP##u_^>$]U9a3g4h'#4dZ(#,sgo.]nr?#_2qB#LHAC%m#fF4X*Nb$Qmx6*/oGg)mc:.$fahR#k/iO'?0,0LKQf;-J*;2%*l0#v62r;?MvUpfkog`NXDkT[R;$Q/a@0F*<x+,0Je:p/GoA,M`4wvAwXt&#wfS=uSp(]$tU$##1ZaRNjQ7C#TOnE4[j:9/Bo6x,qVu_P%*oC#ikRIM8NQ6%+GbS7Z=1w,U=Nq.MZjT'68RV%JHfVnv8YOMB(c5&nu]?,m?@@)#TIh(j:hh$9x-W-Y;x32&T+L#Gf[%#LQK,.HM<MKS_EX]C0lD#wAOZ67RfC#24vr-VMi=.+^p8.8oc,*4vg8.u$:C4'm[u%4/Wm/C`Lv#4u?8%4&CW$f^l>>==rZ#1_VB49f:?#V^0#$jWWZ#WrcY#iH+U%V*p8%H*XP&F+&j0EONT%FY^p7;;alAZw%j0&j=q$(0DJqgLFq&^CwQ&kI%K)1el>>kmweM<cl>#3GAjKc*dkKP0E]F5?_n'ML$##3mqB#)^B.*lTm+#1^07/?29f3lc_T.V*fI*sd1g%H(C>,4r0f)nl8Dfo/>Q$5vl,E<wCk'[#QN')Q6N'I&AKqVvbQ/1rT[QjM.c#*RwV'.FXN',80e=F*,_J_WZ`*)7Tp.nd0'#dA&Kk/aKS%k9p7&m_3m&u5+%,J@cm[JK=<-)HTk04P,>#kpHJ)i5/%,&lM/:3F@&,nb*Q&ZJjeFm>,&#nh%nLVh<$S(EGA#eTeLCo=-Z$Q.<*gF@xC#;O>v&:Cuq&*<jW^A3Ac;)PP0&+eH<6qR[>62]5W-mPfLC<`,W.xPfLCgI(&P,m<u1E-GY>Zl0B#PYL7#]I%a41]^_nFnqwLRNK*'1i_K-X:G%M5DK)8Fev`43_Pm*VecTW@ixt%YNbp%?3PT%'6p*%g-ZZ_S9Cs2YH+F7oEUpB#4&v7T83T/2Mo+M,9o6%SXnY?IPW,E:`FgLd'Yx%a7e/U(.3-,#e<72l;/3/:DHT%?bN-Z=?'MWi&^%#sDFf*=ufQ/Rq@.*YZ*G49<ED#2`.P'gIF:&e)g#G(V[%'bmPV%/qYIqbgxH;uUI&cJeuN'&O1A4ZWL7#=4i$#xjP]4coTi),VW/2_w`f4>0.b4$sUv-/J*+33QM(G$Vk**M&I)*a+h+>7I6&'N`Gf**2?v#A)/W$M7a'M,-8]IJ_o:/*Zco/,&=#v5m6o#0/]^.bQk&#e9cK.O7%s$PLX^=e0g,3P9rI3UspG;qmj/25q'E#0k^208$5n&e7MZuL[?-dZ?99%B,d2T+=aW>.'EVn34l]u:`]j0=_V6T0fr[&r]HN'@%SN'KdAq$Dqp(G@dPW-):KU)R>K0MNjX>-5?f#5&&>uuEb/E#$b($#Kke%#Ql>x6v+RJ(6Ou)4>&oL(6/QA#lMVO'EEPJ(oQ2#P/ZaaaHGTp%IYjZ5+>Mm&guv_uEOP5&2@t.L91*L#E0nS%SbqXM5os.L[<1_A_k;##O%fc)7pWgL5VkD##j$30J[29/QT=*%rNSb%=ZVI/7V<Y+^A_8%jFCE+/#q7/Jbe<-Rf%a&>MF$>j5P.><SY2&%;s]$f_LgCB,nw'PFj8.6/^p%xR)aNB1cc-jEIu0T_d##-V>K&7]udMTT2;?,e./?IG:;$lics-Xt:oAF`vU7NGws]-EF:.:fcs-x:]8@U0?v$mT;^447T[-S;V/2/-97;jd^d3W5[O'[S96]7wmC#TK7q-N,mA#)kT1;9QY>-rNXvQ``0HMi3Sr#]M;4#.jd(#_O>+#rqXI)]?A8%x&9Z-^5^e*PQHQ/cI_Y,h#CD36hWs-3^3a*?#?<-f(H<-=OfT%G*<T'Q?F]#PO;Zu=okx#^KPN'?H:KE`pX=$d#b#=`IYC+9UC<&YYw'N%2CoMZ)?%NN[nG(SV&e&kr3i(v#PgLR95a&]S;S&#FNB++N'9RJWD]8TgRjk5r5<-*U&,2%,Y:vsiqR#]d/*#l,>>#*InG3j)^c$.a_$'OHad*:'?<-O:V9.xx[]4Be_$'&8_G3Td*gL7g(e20l)?#829E<=m,T%7F<5&jQ*NjnmdNBh*/30@qoi'k;^;-r*pJ2p:qN*dXo/Ld(J9&<PRW$,m8,MXJ;I2,W`0#%sS=uT^^xbAQ=8%f^]f$G1L;0_XDE%;7?QUDkF<%rxI?ppUG6s)bVa4Uk5e@Flo>85Cs%,uioNO<I>F-FxlYu?a-t-I7;?#SoA(M_XDZ@Kkkv-bqsUOV'G`W#LFc2TnV?#XqUV$NrKdMr7U*#QJce>JoT,N3;jINc)vw$U=tD#`1[s$KRPQ'hbK+*4LugLT?Gc,sO,G4fh_F*,PsD#ZD.&4^A%DZ?H=GJL+=mQiC.2YEn$SVA_wf)i7EC=>XjP&]R+7:?@R8%/owr%;..s$ST(g(GQ1g(G*Ft$>bNp%T#juLT)oGZQK<#.`D&pL=+xRV.`#Z%9&ef;D*X9%I$J[#DIiZ#NAct7dj5N'cN=g1D(kw$Cqa9%j8s22+;G##7NUR#fXL7#A@%%#+]&*#Q=h8.J]J0Y=V'f)6@L+*2`&02ickMCC12H*L@[s$YKM9/<iXI)`9K:%ja;2/JPo=%`)5I>Vrgd4sJ))3e$ng#TS)2KZ3eK#ef(Q&((%T.*n)D+,Fe(%Hp-H)>pfY#46A88eoMo&'P3O'-itW6cu7p&oaE;$x])mf$aTabB:m7&>d`G#<;Nu.-rBi%ORBh5;/Q;$e7VdEO80q%kkQ2PJ%SN'@L?N<:lUV$3Qqx4QYr.L7_JM'#pQ]4kN%##w-;a43@q_4pP[M.gW3c4@_TK1<muX$GMrB#[7%s$%A:$^V#aHk8htD#i48C#H7=01H.Zr%'%gxX:_LR'.AH<%Yw/GVHs7(s6PHT.i7ED#/fLv#TCnS%lI3p%MoUv#>7C_,pFw8%poj*47l-v$kkc(+.ceZA&guXf.#U(,&EKT%.wq;$lWe],7TP#>5p_:%2'k8%[>cuu/dqR#m'.8#xVH(#enl+#j17C#;(]%-GPl%MARUv-58xD*G^E.3X1E1)c^5N'%e75/Ab#V/k%AA4Yt=X(9]j=(=osx'Hxe^7s/s;&#t3?#T+V?#GYY>-jCsl&P']S%u:e8%u;rv#?7Rs$]IVS%w17W$=>3O1C[Ep%(fNW%bq26/lT'6&Lp-H)LIes$TcC&ZwkYT%^4%w#3;-t$>g2Q&/DN5&TbZ>#]^b2(3u?s$VMP2(bu^x$`kDJ4NUup%gW4K1*%GT%7r%>.0&]w'#T/B+97+9%2>###]3n0#u6wK#e:go%GB#,2Q6BZ$D%fu>Eq^`*da0<-=;G)%QjE9'%L`p$ikhDNBKaYP=X,41$)Tu.lMTE+wOk.),lYW-(s%iUGTWX(7+Lk+d0uc.jF9Gjpd[ca+okA#;+?D-psP<-9c3=-G3u?-t=58.)&>uu*IhA4ouv(#V+^*#=*]-#ux(u$*W8f3`APIDlcl8/Jgj/MbKJw#/7xM0HjE.3V.@x6g?%lL)3Xs7+1t89JlBgM5IlD#R]jj1GZU&$qSID*kh2Q/[?Ib*)>'32ES?S'_HgwQo8te)U^Zq&fc<**4(q+*A;vmLxj0J++i)M-;Q,W-cov<(>R']7=fuY#E_nW$0X/YuQLD%.ewZ=.oLR[-:Nx9&M0S=DxdoE++*>K1?JSR0@KKr.RFX+3fq.1M2H5kM-U:)FGEGSfABw_#.WZdF^gcR&6`c>##wBi>^Nb0>O:$##x]s[tsD%)Ngo$)3.V$;HPV'##./`)3$rh8.+e5N'^4mp8IlS<7tO,G4O4n8%f;Gb%5cK+*kA1C&58Ib.@Z5<.RM7Q/?RT:/p'8[#sY4j1EpX?-s,e#5*Zkv6tU>c4*c7C#[`JD*eL*T/*.=x-WqaN00H+G4$rUs-+K3jLPgtK3J29f38qs>-KVi:%`2V0(%3oE+/B7N'j`Zj',UEN9Qw.[#o67t-je7@#<eN9%RLOn0>..W$(A+**a,20(S6=9%bQjxF_pEs%hS(@-95ja-*`X$Bfs?L5js<[9)dT@#viQE3p%j4'+.MW-6&%W?QM-j:kbEZ#c)2K(TC2Z#P9p2'<RA2']>7d)*cKp7gmg6&`;rk'qi:U%^2^5'Z8Y?-.WZD-E2N:/kf%l'tLJfLW$euu7m6o#Dv$8#ouv(#Pb^=8?07s.%Ib5/k%AA4+R6.MiUnJ;^p>aP:o)G`?>k]%XEFT%5jlYuqVkp%t2%w#*@vV%9EC[-;%Ow9s5mr%lc=s%t4lW%1FA#,'c[)&vKi%$8A6`aSH'Ab?I,879g&##5rU%6#?rU@kwCc%nv;O+Nc7C#-@XA#l5MG)je&N0#c<9/2,h.*w7+gLCD9M)#or?#MYnan>7cR*]W)c%4Zkv6Uq9:@S4hSK]v>R&p3Pe$TeENTki7@#^[r1-W]/b*qv>k'J[k0(I=xK:[F3p%Yg#3'K6#R&x`8m(Rdjb3Ev+:&>3VC$ASN5&TC'QAWq[b%m]=I#_.4i(k9bt$]vC0(*UrS&C,uU&jiEa*D)@s?.on%'Ok<=$(KJkLF7_L2mrr8&?tOJ(/7l**Qb+O'*liq1E=YjBmPea*=F3p%43nmMO]>C/aHtWUZ####tVo9v%b/E#i4h'#8sgo.Zk[s$NI3u$'78s$ghh8.NU^fLP(NT/>'Y4WHSg.*W9%J3=^(WHs>cD4//EJ%e]]+4HrCZ#FtBd2X4Nv#T/7H)L8wh(q3k**?Si;([f7G6:wqO+U3Gr/p,=pN=R<G+I]V9/nfRH)io.P't)Sh&so]r0)7bX$$NWN2JU/3'o%:v#-;t-)'4Rk*j=b(43@r4`[8Nf<j%fH)nM@-)uq5C+(f-thY'sr$wloXu'2w.L]:5;-%E#,2]1eu>VB')3)RA7/lZ*G4L@Gm'mt+gL>1,c4N2'J3Lax9.081`5[uXb$uVW#/[::P%qEOA#B.i?#3GO,M#8T;-s]h@-ML+U%/'PA#n*3P]uX/A$5;[o&DXwW$Wsi8&P@?$&?Lb^7%(lQ'L9Bq%UYC6)<o8gL^WG`WB_jp%U3]W$xf.p&:K&M)&Mcu%B,h1*3Cuw5YFs4L+4>l$k&-S&,4`J:;[aP&]'N?#ql/&vhH5</.gGxk^3sMMRkXT%,%cgL*:S5/MQ10(L,vB=:Sp,;Iq(f)UWo%#e6IKWj/g%#oPUV$B]ET%HV>c4rcMD3QElc2&V'f)^K]s$kp/[#Dfn$$i.<9/N^?d)&i^F*a8,x6NSHt.?_#V/4&N*G@D$406HkE*XDrO'L41k(>Aq8.ZR4U%-3.L(6=mi9ZL<p%=)1Q9a4kE*#YTF*:@QM9]t=/(.+CJ)QG%P'gX/r%W8[d)o]0b*5B&^+%2>t6KNGN'w.2>$;llY#w7a+3M^53'F3T6&-BXF+Y(]fL99,,M0*A`absNP/An_l8Gf98.J1=/%m+ARj'%x[-So<NN3_lL%%*8f3&7&s$]JUv-RvNQ`ZJOl]dj,n&?S[&,&T^[M.AjV7t]vn&%U39/*oSU/,wFO0mbhw,U2Bm]Zr=;-NP+q&hj5?&m?m<M&>UkLM2oiL1wZd38#Fu-^45_+YEBQ&.####bJW[]eQW$#f&U'#Hc/*#rAxM(KZb-Xek-@C.B@m0xkB*[*)rx=_P[`&:'+W-R:Y0PxdAx^bc9KM;uJl%LRgi#B#L=Qen%pAZ^Hv-M&@I/+xET%d#_HOEY@Q-XWGiXjhjc<Hi$iL_R[b4B-Tv-$d(T/?;Rv$r);mQ4$*D#Ec0f3Y7]G]jSd@-hmxn/`cO;-Jlb[RRC_kL;nO4:_Mud+S:w8%#XQc*lKfW-4Vx<9sA(-%&0n;^A;gI*/auWKOq]:/&/V[eW(Ul%$O&9.O5+%,ok%<-(&U_.MT*r7U55%P]At>-qqFgL])E'8p&c&#lCKp7;Uot%Uuou,0AR]4`r1A=L>v1KY?Pd3KjdJ(x1l4%1[U:@Ke6pgqVZI%p#[)*s<RF4g_158VL-_#bN]@uDOII2ZRA-dBO)%,;FD#e7xc<-E1^s4:ZWT%G6`Z#iPhU%&^UU%^98@#Y-81(e/E^uoB-_u@^r%,I7)F(uCL^4?J5n&`;6V%Jh.%#&2P:v:q2##L`if(DqCP8KSae)ig'u$gfUv-?D,c4Jva.3OBRF4lbkw$m]q5/blWI)kL&l:w8&+.?H.)*O*r-4oM-C-DwWrAx$nY#6r_v#q8co/vC=gLfuMw$bK&r.*Z3E4@7?C+cCblA$A&+4vPxL2tu4'5G@372`$0q%A:7<$8I&(MbuX'k:O3p%H3KQ&%_v,*.Nds.`;7qndD24'^Ei_]w.lr-u+@PO#`8PbB68;QDTXD#)iRXN't,)OP*7qR#kYV-Iot6NLJf6N1A<I2eJJp/^,HTaq2h2DL_EN-9`AN-.;<jZN_)_].Ibd]i#<A+_Bgw[X@*11;If79j)m8/TJes.+h<782RY2(C-Uk$Bg(rBv_#.#`G_/#w`/A=K6Q,*R5hW$#ADs-q*5E=n6YR*4e3iMZFeY'iP#d3(CtPSF*nd*a@mjKX4V9/D15Q'_(4I)su3@]Z)E.3]@wP/;Mx_4NNg@#D8'dM=^@S'L9Bq%r]SSSpCndbBDOJMHj.FQWdRIM%xdiMr;pNM3#29//UFM$EFR<$M/I-)e+Kb*_eU@,Z8Z;%h@(i)3#BB+.Fi`+,$a*.g.7eHqHwdDY;u`4KhL50m((@KjShG*nJXX(u]a_&4Y:F.]+X'Av*ufLWrugLu3x0)tGMK(ajJ[uamjp%9nUe3Ing6&T/L<.1GG##t+Sg1;^U7#6I5+#[34]-[+X5ATa0rC:[kD#f5)c<?-Yn*DrU%6o:gF4Uq_;6mb7%-^frk'&VW/2al+c4#c<9/jBFA#nXQ@))&BV-t&0f$iq@@#ZfrQN<0</M;/h30q>ZV%6V@Z$ELeW$sd/+%>POI)2:_T7j>$40Xi5C/1BTe$g>3vQmY:C&8ip/`'0lT%m5UY$aYT5'j#%+%WK*L)OoU,`KmHK1Y&U'##=M,#P4Ls-VL$b[+EB3k9^U:%^h)Q/XdLL.qSID*`#SU/#qVa4>U^:/@=@8%.NA.*HEe;%4CMX-Nh0R3LRM8.uiWI)&V'f)$%?v$ULBl)nLND#/*i$%r%.[']+,N'bB4g1Cp8G=[x`[$BnEt$TQC80,7nY#W:C[9fYu>#$>w21csiE4p>FX00g?['7mXv#H,:V4t'Tu.>+H(+=Vb31Dr<j$H90U%%C*^6#i&&=%(Yw$H[@<$A4A60@k,&4xq)v#^GOgEHf_;$d]H+<%I_41ZRu9:d]6]#Vmt=$[G>cEc.UiLHU2E4FWmC[.lF?%A7es-j?%lLn>GA#af^h&:M3&'PBL4Kh+wJV93)$>qx8;-qp>%.Ft^`*M*VX-b><r7#t@pALm3/M9]sfL(Mvu#-BTs-N[3X?3hTN(jAqB#6Gl/MaP&J3>)V:%/LL*35xrB#ANCD3U+BJ)u'nof,SSfLmai/<X`+t&hC5Y#RwC`)a^U/2fl+G-P-=;&9j-n&wbCH-R-%*.jbuc*ERsp.2.92#7[bZ.<_XD#BY0f)<Lp+M[AsI3O//:&U-J%(`/0i)p0Q=93KBxZL:/GVOcSBf1uRpAlN&N0lpXPSi=^u,edNw$q/Biu%]r%,[.PwLU41u&fatG2,?a?S.ecgL=IG,MX/'<T#rJfLXtHuu5dqR#VYL7#Etgo.R4r?#S,>D<i^a/2@T/o8'x)?otS1ES$0Q.<#XNj1l&B8%=EJ,M=htD#L(=V/rl?m/lHSP/k%AA4@Gp;-3Wvp/BG#v,R[<9/eF;=-oMq8%-GAHFKB@:7jqH2M-j?lLJD/l'u7M_&jdj?#rv)E*qd8x,OgGj'9^Q0%@ws9%Zh;Z#DqNt$-(-:7n_&Q&MmhG)Z5Z;%wlc'&a=.W$Xg^[#-ZqV%Q%@8%j^l/(vZrD+6fL;$'=)N9Fva?%5P(Z#m^Wu-_Pgt:Uoh;$D@es$P9OE4B0gQ&R*49%5C)EumET_-TYp9;%DF,MN'q2'H4>1DS]/^+fFGC+:uL;$$4;j9fj^79ft50)ekjp%@mIeMtFZ.<F^p8%g/Bq&_)C:%aatT%mV<hYeE:,)XHMhLdw(hLKai,)J6;iLX#Hd.0i-s$um#`-m_.S<Z.D.N)gXpTRu?>#8A6`aN_4Vd7`###Gtn8%E^os7/Z4K1JC[x6.-[.09Tr>?(i9E*q>cp%ANnT.*p2GV,/eX.&qi0&)o=E*jc*??:^<b7YX$##%&>uu1LDO#exK'#s$(,)ig'u$^#:u$BKc8/>NQ_#OJ,G4BY9+*xQ:a#ZcPW-2))C&8a^/)CSwULv=N/%vA>E(w0a?#1t$<&U2*e)ft@[#aXSM',YCv#+=Z;%5kQ_#m#Uw-^1),+SQ^6&YILk+f&4dAYN`r&:&Dk'A)4?,>EsSA(jgi#^[D'6LQ9U%<;MYP)YfN..E3</#uoJ1>J>>#IOxUd.N4J_wS4-v@@@7]tj(E4i@=<%Q^n)3wHeF4%v)D#rPR]8nqis9gxiW%6T(T9Aj=JCZ3QR0&eH*Nef`S&H+i._.c&3D*Y?gLTg0N0vv1qB&V*R0e,_6&&VgQ&UY_uGX@Jt%Y7PV-@q$292g#f;a%:B#?S<+3o1(D.#Co8%cR,'Zt%,G4[m5%-5O-29<n0B#S9Bq%(P%pA-]kA#`Mou%3Y79%fkn9%8-X`<XZ.%,54S$l_,EK$_-$Y?.pp/)Ph%%#s7TN*pA#&#_,>>#J+$b[-BqB#6iZx6Kf^I*j$%c*[jPj0p*D.3`s-)*s9uD#8x%-*]::8.']is$V2huG,+7>@wi7?5B-PJ(^kR9:jB:=%WFf?NuZSN0V7ep8adAJ-cwYP1`Tlp%8P=>9e%iE%BTdS&*w`A5qV`I2%/5##JaqR#FYL7#vD-(#htC5%x]V(G''6K)%m8+*W&Qs-MIBmA?^4K1=^ZC#vH=GJQrko&kB0n&ju>b+Y5mr%m_ur-^m;m/d?&n/;-/>JbqR_H4SD_&FI#w-u.er%(@>gLZI`RB%TET%w6@$#)@?_#vcS=uMl<GMjsXc2;kjH#U=gBHpSYA#kV3a*<]x;-aEbn21ndA%q8T@#<thZ,'luN'4,eS&EHoUd9c0'59Yhu&NqK-)N]gu&=%)n&VIa6&QP,nA96a*.k#w('m79+0BvGd.gFYF'mDTC/q4>>#BiZ.Mg9_;.wN:tLjc6lLGIfm04hnQ/l5MG)%(cI)eF8g:)4vG*lH&iGN8G#?U6O@Ta@5p/g-fYd4*Ih,tNd'#+f68%;L:`sWBRS.#+&32TW(E#G`wv$7QCD37(]%-Gq[s$nEZd3jYo.C#v7V%Ko2:8%eJ>#:&(N2e(/t%;0$6DVek._L@&30&cH>#vgYTBJXHh,w2)^Qdu*(mYe6##koCG2J3`l8p^%##4I*r$^Vd8/OM>c4]c?#6/X<j0J29f3;jE.3jpB:%&NC%IG[^C4B4vr-KSY,3/J.3W+`kbbSD(_,P`ZP0RGMP06*K7/HoN/2jwDm/,EsA+6u([,TO^Z+wOk.)Xjh;$3Xl>#1I.A6;bFU%m>5m/[LoQ035R?$OiVP0>pp7/L1Cf)?E)n'<9&A,L>C;.d%GS0xj*H$Jd-d)Hr@QMsOPk%W<AqKUU$lL27((%sUFb3UDjc)P=8u.LC<t-mEC+=N;d;%6oL#=b9*?#3B/[uE]r%,BDQ[-i'=%'./Wt(0RO7,V5do/w0=E?9/:%0SROA>Pn''#E4bm-YN:R3'EC_&eWjn8bh]&,Uk_4NBrJfLY*euu8a$o#;WL7#Ie[%#mj9'#?_o;%)QGp.K5ZA#+Js9)Xq'E#J<k-$<X8[#D2+E*.W<fq'[8^Fr'CR'N6nS'n&tj0Ngt#'TC^U@;=XE&Mw(X._KjV78wgt%&;AgLjgXZ-LMV_&Z$hC*iF36JmvR/M^dFR2_heT.UCT&#`P0,.iw9hLlnneMCK/)*obQP//p^I*r5]guGWG0(nh.VmN+q4L(uqd-s`v9)h65/(wI620KpAU)vc,U;/Q4)b3O)qifgw_8oQXA#j*'I?jHuD#)QHN:?FuD4&Kn^NVU)R>&L(^Gkhr62pJ-pSc[&n&to69IrccrHSu=p/<I+Z-V]mHHi?%).C2E[&]m#n&I/N*IS),##fhp:#dC)4#njP]4>Hi/YM3YD#ANVx1K>VZ>F>2Z>#HCh1/ZjgCTC#hL(mPA#j:;$#$)>>#3bhR#:PwA-8xKW3sSGA#?sGA#mIYkOD'k/Q<xhH-ZIwA-5.uD5]rgo.7u[%-Ie%s$`Ld5/OwAv-t-iI3x.X'8Y`:v#R#fZ,cU3n&K''$.n'cgL';TSNofB(M0Hv<Mkq4:.Vq'E#V)ZA#lAqB#ulqB#c9$)Q/$FA+s`/L>dgZ&#R^_Eewrnu5WiU/:5UlS/J-3:'-AsgER1p#ICu;9/SFSV%JPW)3Rld6&fUgQ&B2t_.fGG$G4aWfMY9BSSf[e3WZ9qi;uQbA#)rEp.jpB'#5.3.+=bXD#+gB.*_]B.*p+kv>*H+0j7nCJ)I(^:/Zx%P^hVnH)4()m]4toc2jd0cV.+CJ)`f+%,NgAE+gpMk+'O%1CWd$H)Zs/ppPRQ>#s[X]+_G>d3jL-29?X<)u0reC#D`;B%t,1c%HUD78K9mAQJi1e$lc-`a//d%bHjB.M8=>)4caoW-CdX^9:&MJH#w&CI,OHc*hjks-%eDd*FPZ&FJ63D#d,;mQ_7F#:Uj=vGW'3)%/TEt&413AFP[jJM/g=,Mp2?j'm'4[9AJb?'S=@<.m-mm'JNXA#X?lD#r3lD#C5e6Mb.ilOPg2YR:@-D-0$=7%aZ/i)8@'E#Ze75/kh:8.x5MG)lF?`-*r&o=vT@f=dcf+49U$]8n4])*3ZWI)DGoX%rwiY?=#J&#?CAm/<G?`avSU`3`7$0b@Vd8/e@)W-hiR<]*$AX-K)'J39T5W-ac-1*L7<9/>Q8S[dFBJ)ns[872mjp%QuSS7@PT>&)[[T.9HB:%=WRGrosC0(4ES/L33Da3Z8Z;%]I=7Gu1OS7w+e<(ShZJrO>qW.V8Fn.>5Z,%QnIs-CT+T8K_PH3>)V:%8rPv,uwF$-%@'E#o(6]6'jN4B#3U>??'Xr0oMqp%mU/^b%#]P'j;A+'=SaS&@63W%?IUk+*HG$G'Dbo7Rw)0r_$)>Pd<ai0c*U-M(2]k86<9Z-]U:p7(6^;.e?qp&m=D?#Z?_a<7)'Y&8iNE&p`c[Ji3;TNure`*&HhH2T&4d<9W&F.@Z$I2-*c6&G&0E@-^xK#5#x%#$sgo.D`SQ_cYfF4dD$SLRDG1:W5YD4#_-R'O%%a43<wf)D:AT%*^59%Of^p7R$R)E/S7x*TI640nQl$GC_39%N_/F.H/5##><hLRCJtC8<&H,*@/)pRAsPsMc(_kNLO+J-D@7I-rHbJ-xa7m%d>2E#<7>##5f1$#KXI%#A,>>#R`?<.ae&>.@uGg)4$:u$rdK#$]Y9<7es]s$6l75@C1079(f:6L.=$UCPNl>#c98(Om=KP8cmm'M^`O[VKb5@-'PuY#:S)]bgIE)uU+ffLeM?>#6;6`a[E<kF`o###-xHq$d3YD#vIa$sw^Mh)Z]B.*$9]_%]_;@&)#X)>j_ox$U4,J&8]Rn&1DIT%hRFA#uXS]$I.)Zu9aDYM/Nu$MYjV7#lUcmh@wvM9R/p*@[q'E#NNg@#XNI:0^(Ki%kLs%$MHf6<6?3XCQ<3X&W)sH&(jD#5U7u?,?4Q91$),##;j6o#&_U7#pKOH8H0.O=gc``3?;Rv$Hs=`%vabW-:,hUR[lsJ2Vw(Ka>a7V#x,:g<SQ^6&<V4n0dWDJ)[GMiL$qoZ7#WR&#L5ZI5f5wK#PZI%#YH?D*lK7f3bR(f)QUe8%6F&krUlB>Z`VYu-YQ&#GDTN2'RN7Y6q40J)[x):8Yai>?`&5u-'O=_3oo)*M$M):8B/pcag[4_ADOs`dS?r`fL]l`%lm]c;M+p,3l5MG)00tV$0=rkLnxlhLVUa8Ab^,g)Dg#K)'m_OT+qQKD4HNf<ru`Q&%W5s-E2Wa*pPFm0pg=KV93dr/dO(<-JX1p/JA+$$9DH%bbEq^fnv?D*qAJaH7(kf%u8nt/>p<P(iw37/C:uw5pCf`*Xrj9.?m1,'vL>K+++?V-w:+.)%1##5XUoUd6c68%Mn6`#%,[0#n2h'#7pm(#Qi8*#<sgo.&Sg[%l-YD#N<Tv-Y@u)4;T#)<a%,oJ&sl2rC,O1))87<.K5^+4,<8q*(Pm&4?iHT%.Ru/(/`Cv#@t4j'F*'U%bNKFagL#Xn4HNf<=jRi+CaZv._51hLlxE^47=.[#6FN5&i8j+l0@E]&r=Mp+)0Xa+mICZ@g7+WB1nPX%R2Puu.BLn#n-78#0WajL#o=c4SaJ$MxX(Y$R4r?#xK75/+utA#-Pt7:%6J.*T=)?#LAQb<I(B=$oDc$G5Ai+VBKhG)@<*l]Vg>7&ZvUH,0mc9%,[3ID;(G?%F.eoL]J)W%Ge2'OSSjA+VF8Yc`MMo&>Zwm.AAWK(nQ3a*[Rp?L<Mfo7?&72LV$s;-th>Q1Z5C<-FArq-9`]U%D,P:vWv<##?7:;-n1S_48tFA#ocWI)]_d5/s/hf1'i&$Ru<lY%0tSc3fFs_,A8od)=Ln8%f&/F4tMFT[r;^lSD#-b<pGc40i^iB>_Q>n&cP>B,Irl>#LOT6&rr`R85Ht2('5a.qHXVp@]3=&#C9OA#^$Jw#0ljj1#.@x6G%AA4XV+s6.iMB#2k:[,91&),je&h;=.sV$O+n`aY2Vg(/>CS[Xa6a*81ei=M*cT%4FIWAS-2Q&>xCZ#%BGYuH6cqEruK6;B['5'#u;Q83Ss9).)4I)Ui[C#iXk1('0BZuJEV?#.Aaa,nFt1BHIh7'h*.5/>X(58oUix=hSm*3jpB:%5Yb?//W8f3PwugL2LXF3ui``3E9rk1Lknh*o'/V8ww(t.[q[P/`Cr?#_C3H*K29f3klBC%=Dn;%#ww;77QSc/,ig19g2LB#d9Bq%U'kp%2J(v#9Nr.)QBER8=END#@PC;$Jdhg(JYl:.fv?E*Btu3'[-xW$Q>+.-e7'JI(&Fk'@>5pDvbZ6'Y<=A#@6>3'IUV72F-:]$=r:Z#FJY/_un+M(ph(@,G@,hLDl$AkDec&#SoIfL31YS70^g'&H*#,2WkQX-<k6K)eHE$@3UkD#T2s<.K)'J3TEW@,LKdd3w:Pk%qU.F4pDSS7u1,;Q.iBJ)tf0I$A5m'&S[A(Mf_UU'<N)H&J=D?#7Ji?#K85#06VXhL4s2-,aM:&5`Adofab$LEV_d##L38R5l1Fa*kk]01Ne4D#+,h+>5cY'4o[Vp$V76c4V.gJV12c&>;'u-4GG)qL+#j0(M#N&#bRe8.(*V$#01jt-Px/YIYJ6Z&=sLX8K4am/ew*<8GN*A'_CwW-c#tG.Xriq2V2PuuMOTU#>ni4#^d0'#]S#)<_Zdv$%kBB#31=n/:N.)*c#)T&<B<b$.CEw&TkV?#U,AU.qmlS&)d@^$0IEw&TeM?#J+AU.%5YY##QKS%.rdl/BBGxQ)[7#LLHE/2o>,W-aTK=Lg7aQ&.:UdMkv9Q&r-)w,`'tfMeqhTMBU47Mlv0Q&bBTn&:=OX(T`4JCXok,2j^''#urgo.$uh8./&>c4(cm5/gt_F*3kDE4$xn8%i.q.*6)MT/WFF<%(ffx$Z,u874w#8)U6U9ChXD@,hPxF4*Y0/)G??D:.G42(s[Mc+L^;A+1o'f)km7],ulEY/CaC'-@hI&,vksd+BEX^,R$m8/Fv[.M7_Cj(aQJQ8)kOe$$0;*#<CCgC:WZ?$<tfi'SVW]+q9x'0b$(,)8bCE4+V)..-uxfLnSB]$J(-xLlM8j-^kp6*2:;H*Mo_D4);IW-mF9q#:Z1iD4pU]=Rb9:<^QF?#a>Jq3Nu`v1EXt@7nMdt(7m,]M>2Y?M<>1M^x.C71pxbTBwNO,<,vNWS-m8d=E<:>(`QlDM>l;i-nxxgkhgJ%#epkm8,h4%P3D3x'7*;mQ8')HE(f>C+?m0W$8)V_&7In;-Ze7u-/;`PMwIN5G2*$Z$5ep/1]nl+#h`-0#ClP]4:.`p$WMq8.t-YD#wXnp._R(f)fwpU@fG[m0s&X:.(=vn_@5gI*1<GT.*EY=7IdD.&=3M^>_UeA,#B(]76WgoLvQX:.cXd4%p.5k:VF39%/:FT%+41hLnLOa*nx:?#1i:910ue<(8%DT.Ia39%h)Tg1@feGVl1A2+T^^u$Pi5lLrx_u$tINMK49HN'J6Eb.X%db.2x[p%uc=v#/g/,N&2.Q/V.`v#;S69%Z5Ms7hj'NMOL2V$L1Nq2omP7&vf8UDY-;s)'=5#%8m3fMA&fS':%:i<`/Bb.MO/#1:oLJ:xrP<.Vh$##QM>c4]ci:%2h'u$_/_:%^#YA#V?(E#jpB:%49Q.<nBO<oJT$Y%XdZN';Bw8'v<<6/`2pY#:fCZ#F;5fa]ZajLjVdYu+tR=%P9U+.Od>3'bdpQ&>edY6ds7N1CrFJC4)UQ(?XLq@XT>qVwLO&#/Xsn%<?uM0E@%%#Uqn%#(%Dd*^HZT%ne,87Xp[i9i%6D<#1fu>3<?PACGo+DSRH]Fd^x7ItiQiKQlRfL24%E3kq?lL59MhLI]XjL?ePhLWeH1Mw?`8.C@.lL-,7&4VnLhL#xSfL)P5W-Jc-F%e>Bb.(N_$'-WC_&u>.F%Q%j_&u5w92=J[w'f;'F.(`Vw0gZmS/6cKZ$q5(r.9vcG*5LCB#eXrh7hk7L#%`kA#N^c8.$K6E#Q2^q)]T9Z7.IMX-fV:U)^-UfL@RM=-Rmcs-=&4GMAiqwMKiW^-vk*R<[QHb%?K_'/^.'7*f)*C&9iu05gpH]u8M<kFssw9),LSh,1]Nh#Ps_t:pc[O^3[uD45dkP93hYH3vxPA#]nr?#*mJL,8vUG%;ccYu*GlD3V*KN'w3pauXb3,)V@oW%6)2H2'=)W%2=W3&=*niLx</W$0M5W$O:m-N?Gp;-OC-qTR$+4#$?$(#DkP]4;JjD#q3q+MhPK^$*H8f3MV&E#tt[:.@Cr?#Lkc<.n[Ex-0S<+3svEYPxa^/)FkWp%)WKTRN?C%b3VJ?5_2Q7&B35j'BCn8%Q^,n&8D*T^toeh%`8iJ(r<A9%P_`;$[whhattGG*e%O&+s)gW$bdOt$%M3DW[MTp&3uR;O?tJfL3CUP8BOQJVn'q`$mvx(<.:Qv$@qoXHN7)H*5:dVJC$gG3N2au2P1@Y6=Fr+*Ukjp%Xr^U[BF&spq_B`$lqS-29=w]6QeLR'NRUZ$p'-e<,f><-=>=J-lh#]%p^?D*mT%##JEZd3aIcI)OHlD<Js]G3lo-W-5wetJ.0&],hcWI3dv>t$huc-3W%V%6,R(f)%cK+*eh3n/+Q-i1`rH[-+5WN&^8;J%[XK1gZZx>,U,[)*C01,)revP/O88#,eFvY#cT+T%SF%W$S9k5&XKxnL&J4j1>.leZV-]S%8x_;$',Kv#I09U%D1M?#cq*T%jIB+*JIIW$V@Z>#^*@788a,<.4fju5=6M`$&,KF*,h,V/jW/<-jkem/nB7f39`p>,3>$u'#`2D%#-FZuav_v%sGYp%_<9a<(#h>?u)ShC^EHJV_+#C#/MnS[..Pn:c.Is*]Q(01>0Yp%Pn(9'AChT7Kq:m&8eI4VivJ%#Pnl+#`,1R)0,.E&_'(]$Agk;-WIM;$qAGA#bBKQC>Vd8/.'ui,=ZKI3]kuN'voQN'dDNa*(;XS7?$[w'u+poSgk72L=7BI$++:B#E/)Zu*6x:.wP]X%1-92L534Q'n0hHMFMu$MVtb7MImN4Y#YkA#gvG<-q>#P&RUZ##EL7%#v,>>#8q2-*xn65/YYMT/ZntD#+ri?#l<3Q/V0O;QPSd>>JBj;7b$MkLhY>@P?EKO0:E9J'+g*J3Of(iMr@AL()bQ'M2+0I,VkAm&b[GG*Vh/Q&bO#,*&9>F%0=$Z$]'`B#Y8cOU9xlYu/&;T.Oh<#(OI5s-ot,JMR`T#,bq.W$0#8F%^FIs$HjvD-rrBdNmFt1Bt4,MVO%fc)t#BJ1Hw(588<.J3jAqB#jBFA#5d(h$G2h*%S*@K)^:q8.J1&N0s4^+4ET:u$O3rhL`Kj?#q^D.3'1YX(8FxpA4>M0(xd&n/NcSs67$iB+h,kb1OG=GJe3'+*d;_U%<='Q&gJ3E*_3sMM:F[m/wi*.)]j,n&T]Ss6(E_41&@Zr@PWuAJ3-kE*dM?;%2/%V%Ut@<$v8YkMiW/%#q+wi$#+[0#<:r$#vGs(EFO7U/Z^<c4ubLs-?vX>hbKG8.%2)s45_Cfs4HNf<ZNk^,UHNx/gi;'#&&>uulcaL#/HqhL5R](#t'lI)I*5N'5J@A4kon:/u?g?.E2&]$[d^5/xH:a#lQiKCBco>GlHuD#[Z*G4=9cu>`Ul?,`*GO4n`&QAmlR;6qOa(=l:hs-F8km1VTLiUDHV5.liIv5LC0m&?xqJ'1>#G$SF8Q0X0J[#xt.&GEZ-)*YMbI)L?'32LI)@,2Dko7mGV&1Aesl&#Gn>#d(o,&]3n0#?*nW&aw?##Z=tM(E##YuflES7%####Ep*'%jm95&j6IP/rR5:/9k_a4lT&],Fp?d)xj-??-dEj1:?mcM_aud3bn8CG<00>7]-_e*PB830o4G&%vUSx$'4%B,+Dor64HNf<(flJ)$di21G>K3O-IDD+%J_/DL56T/b5[A.X[ucW+7S'5$Zqr$>.f:d1pKc`rCRl(h6el/@RGS7iB?S'ZV6C#l+]]4BY)C&2#>c4HYMT/cVYD4*V7-*XHhx$.^NjL+#f)*dh3^Oa%NT/7$l]#k;ic)J@<=.?J$d1d+.X-7Vsv8ObrVA-nT99+G9M2[Z:K2CO[LMj*1q/&M&$RC45I<Jlhr@vww-+tM-1;Rl.C#;u.T,[pV-2fvDG-&GhlBk*OD/1R?^+gl]Q'<WuL>W1<5&W_QC+7k6$?p*Ou-xu?C#gMRWA_Gc>#O`#1##.vV%nFQIaQ6F`aJ')58k=2A=5T;MBUkDYGPNEa*S-'U.Jva.3U>un%b&]krV1Va%7^fDNgXB%5:(p.)b%t]+w<Gl'vT/^+#&X.)isu/(3oGs-wdl/C8rJe$f*wcM/'x&FQ.ge$m`U4)aqgI)#3XI)hmT/)H@CMqdD24'/CP/_48F2_R7u8NU`k9'%b2@9$u`e$cf;`&QuV_&lI`e$D*be$q3n0#%ej-$Yl&/L8Aqo%M,@D*j6IP/4MR]4i`Db3QvQJ(oNv)4v;l5/b@.@#o6Lq@c+T%oRSrE3ntSK+PA-H+?BEoAY&4##D3vN';$MDFA'[C#-Q(^u%>,A#$Q$caO4PS7jF$.$265=1ue`e$Gj:`&sSu8.<G?`aG$pl(?x###9&Y:.1Pr_,xgmg):5gb4GD]=%m5/3%5o-YuWVZ`&xr0DjL4&]$]f4e#]a7a3H+w`afbUW-=W#$(q%*b)pE/%#0U#l$b,rE@/(*20n6Ha$xL+$%h3YD#g3C(4(:ff$b+BqBi3T)=FR-A0k4EO:=>Ad<30I1g>OGb%GuqO9$=l%l'rQJV]0IJr$ute)V+T['/Rf'&C3[['Ct[kXC&.GVYu8>,tJJ`Ep)7#6:<Gm/)7RP/cx#J*_?]0W;Npk&%tDJ)`(6caYZa#565l-$)i'B#UmTbE;>^K2.+CJ)_gX>-?j4Z-)7&Xf+^xK#Cb($#I$(,)^M;Qh:k1e3)qRF4e7+w$c<VR>f1=VED74J4PkB`aYr6;ASxSd55W'54XQ`nD#.w.:Wx'm9p]iB,x;#,2_tu,*q%LxnIo9KM-okD#HjE.3iJ=c49#mG*2Ba'%q4=V/@Dn;%Kn*]#K60R/n-9#.K^^582pbm1JgC2'dr8[5`&lo/a4oD=I/x1(TETm&WkQg+/%1I&#>GkL-5U(2Fi7[-cBk$QtUM.0XSmu@xNA30-ts/'$j8>,RP)KEo]fF4oBWR8ctcG*ZgkW-`0f:p&8]=/s;0M)bDVO'YNWa*5jpW-vE;&I7inI%Xv]'/F%[*jY2ZV%%73N&bKIW%9DH%b)A)<--pYD/DVs)#b=ZYS$J*((]R%<-d:K0%Ov=f*g[]39TG;<Bd)RH&7;`]YcT7HM(vugLAqTJDGt'XQb:U1T06OQ84@28]4=1^u7#FT%.:,LOJ4$##l8aQ.huC`a=p9n'<(ku5]>t+;_l#/4c>E[]00xP/BP,G416]+4+g^I*w%)C&4'PA#B.i?#W?ng)3'p8%VOrQVGx?NWsJUh$Cn<Q8<vKd2^xih'L9Bq%qd0f3C4G%XMnAm&:1,`4E3H890tLR'h0]<$^o&B+xE>(l[4CB+3,gKufEj;-fs]V/%u`p%',%cV7iYcaqxOs%ERMt:vQO4:TUp#,O&IH)<_H,*#g@)*c%g#,W9fW$a'(:@aH-v$+f)Nr-RcGM;=CA;Wk8A$8A6`aSBb%bK$do7c]Tc;w'$u69Oo$$Q<b8.3qwX-APO#5CO[8%4oR:/+xI`,X#:u$CT(T/BAIv$j-ST%cF9C4vXp_4OiaF3NKY8/wwVv#lSEQ1l*qP'8L<9%UllY#6fGlL46a<-7YcY#n3'h;xG/mKp9%a+r5sHM%Ls?#D:oUdaWE^4qli1L6Dp[tw8=.'/:*T%FL&h1J5RQ:@ELt8$F9Q&M'96&K$F9%+rqD5ZOV@,U;n-)Iq<G+Js&x$OHGN']r&J)wp4:(iTH1g.m;Q/&5>##4?Ln#'XL7#ncZ(#0sgo.ZktD#]Mx_4+u@`,[M.)*`X65/_$/n'Z_QP/Jj:9/$i)]&4M'+*i+h.*MMIW%b@u)4/oq;$6x&^-p1Rs$gL&a#=&OU*]k.T%8knl8HV3[$cM5a?C_39%lrY/CIed3%=HJ._V5do/9eFL$GHLG)it9n),`hV$D2Zm&?Gq30*.vi9?*KW$s[&>.I-49%j5w)*tM]S.`h#D-Q'[x-Wb$29_a0^#gQ<f/$]&*#MCe8/Ok&T.g3C(4q>gc$,B2%.w=rB##3qH%(uH)OUGC@-w9=g$Y'q+MsbwAMTP^V2o,:F%DLZs%XshfL%DKYc#K4a=4d@UJ&_33L4>,##)emH-DY5<-$]5<-]:fb/dX(%,d-FT%+`kA#U1f:.aI$v#KAVj0Eke%#Z,>>#%i:8.6%8H*:O1x5FGZ<->#m.+Kf`oIxN4P=/*1T9Rx0#?##Ln(,qQBHN.cp7;*LB#PYL7#ccGlLHZER3V*fI*V?(E#+)TF4TMrB#L@Gm'Jw-m0Z%Np.SrU%6+E^q`ufnP'W<eO%e1E^#)H+/*Aljp%:tWN0wBM>P$bHS'jpMWMDhwx4HvfI_SQ^6&p4b;$._HN'4CRm/hEu/(,FXN'>%gN-H8t>&`_/2'*m:D3xWtm/(ctM(WFuw5v7T;-IjDx$j^:9&tr%K1'5c$,V5OL)VDSS7/%/B-cwrO)XNkr.p@,%,CFRb%ERUo7`AY<-cY(]$dWL7#+&>uuSE;mLtD^%#$K6(#T1g*#O#(/#bcgh(Dr-<-x7EC*^m@T*^A`993[NK*0aR5'DYG>u's$-)&964'Ym@wuGl:W$oFHJVD^t2(^J%H)575+%%hMl+pk<6)rr_G%=r(?#ZEm'=MTb]u1)dgLfF;v#@YHTOVGtA+ZWsC/>j(N0<G?`aMu08.-HKe;R$$Z$8]];.[#>H33xWD#A'lg$mhM`%>m_pL)]5W-+TMR*&k8n%93w]%N.c58bN9dOb^&%#m8q'#2Lct(nv@+4L2'NKej2<%0EN1)`?@I-tFuG-/$h5:RuVoa?S39/od;PKYmd?$*SrJUYDhT7Ij(kDi1nvABX?X.EC$F'It,_$p?p2'0YrvAV$&%#jR#t&o?%29xJ]QhNBeq7BdwY6`uWv%9;Q=-?)?I'[T?g%8E5fZWY29/(4Iq$mQD(;wDt>dSQu/([+FcMnEt$%j@0;6d9%##A<V:)?OHg)),$<-'e5W%e[>p@8$HK)1Yi=.4^k-$AR]p%9uA`7_w8F%&%LL2V'IdM]LklA5OL^uD?x.L?4:9%IG70<OOq29f'k>-t4%D&[Jp0#g/oejaH0GVAE(,)h0IP/hSm*3l5MG)`>bJ-B4K0%]qL+*a]Q_#cI_Y,vD(T./@EZ@&-E;6$i4',F`(9%%wR]%ch:r=[?f8%3ab,255fm1XR<j$*ZP*YE$Nlg[VVs%#9<=%5V2I$(lYN%rsH&m,4t.L[<VV-Tb$##MR[GEBRt,Od;E.3l:9o0:u?F%J8=`>9#q?-/x34'CvH-)$U-TIJTuof(5G)mA=GS78YN-)6kCZ%q/B.$+@6b*h1q,;EYbm'rMq%4`GM]$0t%gL)I&J34.Qk%>2J90s9;GDK=$W%'4I3;Z67E.NFblA)[<AcUv90:cN`dai(`%b0r+87>2*LjrB>&>u7vS/T(4j$Q#[]4V)ZA#^IcI)+&-^&LDZY>(g0^#(Ko*H4FC.&n6JT%wIUG)rwE=$a([p%o4&6*(BWK;-RZd3ELhm1RE11&)a$6M6wQTQg55b%hh2m/%hM^4pgx/1$YkxuKJhw-ltCP8Ll?N:#=FV?'wTLc/cLs-9Ah882m]G3xAA)NBH,oGq[C_&d]tfM3I%m%($+qi,tFA#o+Bf30d%H)efUa4c*Ig)j^GnW]TF+5OmL5/Gr2mfVS[^NunS+MP7r(,L0CG)8)He.=x2I#3F@m/J[r%,/<E0C2Gj4[_hrr$Gr@N0QKb&#8pm(#1*iSCLE,H3c4B>,/BWp@jfpJ)HVgd'OYi=.DAHx0e4eG*&iAN0.FAa%l,GT%rLCkL9&c#-Af(T.Wljp%IGYr$[LB^[e<@],Tn#W.[;^;-K-l?-tFRq$[Bxo%:bj_,xG>8/]wjq.ZGXs6(#_3&fw[p%RA5N)0;;Z7]Z-@5cg'W.)d5t7)CxY-Sxfh5Y2Puu4Thn#Bpq7#+DW)#/#5J*qX8KO:q'E#[q'E#WHMe&gVp.*+Um--;p>F%=Ud--H>v]#@[%$6&pvi7NE)8/[<9W$'YpP8dh1D+re/Q&>n5P1$G4AuCm>l0gq*O:W8Qv$(%tX(bfqA5J4,gL#rm>#_,9@^9f,Q85w#98k-N`+otIu-i3%LM;>(pR43_&,xd$gLbIG,MY:Ds-#A]$5keuH?Q2###',Y:vB5QtL%u7T&bbLS.QX$##?e_F*.39Z-,joF40R(f)x,Tv-Y@cd3&%`l8K>Z;%R_=g1<^mD@6fUv#P/#W$4/KkLHYmD6joG',2VuY#n>09.`qcN%#N93MABC8M[O-##_q8s$u_doBxD8h;UiLC,CX6DE$9<=%I<.Z$i&1w--ec,M)rJfLt35GMK)I>#el9'#N`aI)^8v;%PEZd3%X3c4+[C<?$^Gx6&CcO.QN0b?SHb9%7f9x$@IRs$k:T,MY>.l19&x:Z[`_@uPBnH)m1Lq1Ji4R*c$9@Qnfqu$]3M_#Fw>lfj6Vl]QDw%+q2E(8xCdv$ax;9///EQ/4x)?#.1Cs-7#n,sf.r$-UxBiq=ee6/UdZ[RbkB)NP5(?-^p2*MZ<7Z$V^ZK<^)NO@nm&%#bd0'#HJa)#qLV/s]Rhp$?eNs-G0rb=P//sTmkSN1Lq2mf%vQ.2ZlQX76/&U0QS2;?kqR2L;'?gL`o/q->I)2q=rk7@LcbA#=Bnpg1_YgLf_c&#4N=4%0V-W-5TN-ZOU5s.gf(*4<C9u.c:o<?fZHh,[UBd2*-+c4so^I*-4NT%nQJT%(W5G%Z`1?#t.Ca<KUMZuIYLhLoMPA#CHFL:8qqZ^G8Qq`[1Q<-1HKT%Ol*.)&*D=/RW:p&8mcM9@*:'#SI'&+wJu(31E_n/iL0+*J29f3`:A;%l4$dN%5,G4`4n8%%]v7/8JsILU'LG+j0tNG/l+CAZ<,QV/'=u-j#:^#CU7w#I?e*.Sa.C#&DFN13f-JG(&/$vF2_W.X?pf*_oDq/IdKE<?=.W$gKA0'dkfi'vM:D3KG'##W6+W-/d9o8Gb_5MQ0_5'AvQJ(]w(*4IgNa*),7bEP(6g)2p@^$bYDD3FK4d3;cK@%jZAsnQHGN'n@de$-`061ZLklAiPpK28Yg^%$-IT%&51hLej%HDG3[['eZ*%,o2FV7<MR&,pio--BsRa*I]_W-seh7(?kDf:'7LB#APuKd3?niLPLKv$8%'.$#]Z2(>jGPMapt&#%)5uu1jdfL32ED*svAJ1%ro,37ZWI)?7%s$-E6C#9#K+*cO%:.H#p.*p:`a4sncD4$PkGM0L/g410bs$I6:di%q7L&s$s8%#i7Z7,GHs$YM:t$68wW$stIm&7xMm&Q0r;$kar8]#QQA4e:a%$o,Hd/iaQOEkt8N'mGuP&<;=5&<FooSm=W`#88###A@%_S3*=##.gHG)dhLS.FW8G;s0)=.@Oi8.d.<9/lxw:/YBEDHVfN$5g&sDS:M3u7wJc>#YFc$,EqTM+wOk.)k))T.APsGZ>]e9.G9(sLJc,s-<UZ`E#04m'O:p&#v9L]$-cq9MAV>c406kbHoJYA#G/Mp.^`,29ssl?KVfCv#@Ya`#F%jx&i(ItA.FKrfan*P&xsA<$Lj$AQ+WH6/&YJg>(lKfLAsJfL#.'/La?KJ(4hKfLhJfm0&Z>g$SjTv-iUYV-PR(f)Av5BZv*t,<K)tY-sqRJ3$Vx=-p:PS7i#bD+`^qR#$%:?-%O(?%0'mTMA2oiL4>J-)p864'YZR<_)lE9/Y*D?/CIXqI_CI'&TIRU..)34'Y@L-)]BF$'?]>M9hs'MN3XYQ'dL0+*`I[?T+BqB#&Os?#k[K+*B&H[G:Bav6_T^:/kX,?%K@'E#x.<9/o?d_$mRRmUBeXD#@pTv-3mDF3`QDm$&r4D#q[xAJJ9S>+Zn-:7gnm5/S^c/(W(^b*EeE9%?$+r.6,M6&?tgq)l?L,)W'Km&*Zn(sdD24'@+Ve$eirl0x1D?#9mKT7f,oiLnMoGZ(B.E+sV`,)F-'6&&E@:0?4i?#O$96&=ZRp*[7IW$4<:4'-ujnL3T/*+&4`87g_vu#7>6`a?c;]bU[)20Tb$##RjDE4iq_F*f,/J36xHs-+K3jLW_m=7]?d8/-UbVpBLB(46F_2`/-vF#->,P(`h[[#:A^.G11Yj;;REEEeI3T%0$s?>Z'O=$<sA42^*kp%T&*&+pK'u.+7)3920oMVY/SY%1cn/(k4/L(Qk*d4)SGB?`HP/2P$uZ-G>oNOQ&>uu'_s)#tXt&#eM:u$cfPw&(TIT%B4vr-9O1x5A?(E#nP.&4)pGQS;2Q.UC_39%)DjP0=,][#>j0*<cnDxH].h#&1/^Z,h6Fq%ElZp%3&sO'/DuNFQTI[%u&=7%O'>]bnSmx4l?;U/BP,G4;#[]4Bl$],Etqd-teUXM/tf'FoC,G*6_^Q&RW*`+]3R(%E*?fV'oMoGX6dI)Vp,n&ir/+*QR*)%6hSrNd'N7#-mk.#SD6C#3=QT9)@_F*jpB:%JS+<3GMrB#8I%x,[YRD*[sHd)K,ir?n_@://W8f3$F(E#mX1x5k%9f3B/6u7HC<v6B02iL&X@IM^Kf$&.$@h(d`O;-`dLg(WD.1(?6:,)==Is$8QvA4Rk%[#;k6Z$.$RP+,2#q7OE+6'd<6C'tMMB'(?GG2kXKb*d*0:%NaLg(87@s$,DcY#@`(Z#Bqoi'R#QR&>kq>$3KaM,_2VN'SPmPhj]vj'HouY#fW/<-_o3_$dWL7#`J6(#V]^88K?dTimJ:sf_x4h<ox[/(sX)-8IOadatBG'Gwgw:1s%tM`(`wu1%,[0#5oA*#2qL+*W]nw>bUW/2hE;funPGA#mxG=7Bhx<(GV/)*uYk*.Ws1;?'$a*.rnpr6hu_oIZP=_/or8f3Mk[r%ik;w#KbD@&ihbt?G6^2'diVW%Wa+A#>@67&Dg:v#o-]p%C@1B+,lOn*mS63'?>.s?CaBm0Z1gm&x7R@'/[P-)DC7pED'9q%1@LB+<3`<))='4'u$$p/=WKw-9@P/(UN0S/DIIs$12I$#*FH_#4)U(anC@]b3+GS7Rd(=%1jic)Sv$.$#`d5/p98E4x<7f3x?'o/4(7]6fM:u$9(m<-jd=?-=K6*MoWXD#iq_F*O@hA4[;M0(TPK:DJp9a<6N^a<?YY?6S&K0M:9nG*,^vG*v4Jh(XH;21<'^6&V.qT7.Qp7/0g@/2/o^u$d9r/)cpYP0ttfu.RUX',p3jS(6C#OK^mG7&kJUe=ffM7#a?1-/lAqB#s7v_F^mY#>rJUv-lQ:a#CFE:.W3YD#;ZfF4NwE:.`f^I*.(#V/D25##>hWp%q4GN'xJM-)j689%a3+g1?iR),%GFG2?-p/=wOA8%1)a>7?x&:%#%@Z#6l@$6qa<h#(kA9%np2R'X7Rh#(BlLF%KafL=i'%>^[T&#jOB%%oQ=8%L;<A+L7-AFWndt-=6k;-+c>W-_G6ZAPdCa#X0^M'8Ah;.=V&E#lHSP/@Cr?#$dl8/-INh#&5K+*FgTw0_rWEeGk@5/u@)a4d:2=-BtXW%XOSI*Oq@8%bD6C#3'9',/N>A#pu7T%4<)Q&QvZ)*rH<208q`R8E0GN'<XJ2'A(%w#tJ(:%vqAx$5*0t$wnw8%pdAw#KQl3'Eg$h(3G10*c@>Z,7ox5'Nt39%9V(0($h@a+eCH>uOLk]+ef2S&LBpj*uP[T%M4ox&WHUG)dPh3C[-fw@A1DZ#a-4Q)kw;k)i5h>$JitV-J^ok9)`KU@WQ>/(G>-.+lKU5'%0^R/boKB%GxAmA63ng)lbU<-_='49^c&'+/####&0l:?CbxS8@x_RL0H/(%l<fNM20Ed*;#hs-u`Cu7qtfG3F?1h$k=@8%&(XD#I>WD#3pT%6Y@#c*hGis-CK4f*Hi;T.J&D^#--T_/'_gq%%aYp%s$0T%GG42(4WU#$^l.P'6r$s$8VlY#tU+U&=mqE%GPq?-ppndDQHGN'Qk1c*:TF+5sve1&fw[p%;ogI=lnh+=MPGF+2>kE*O9'u$BtAm&b>Ib#qGt[,KsuM0;bC;$h=l(5%pRfLF$[Y#0TxI_TEb%bTX)20dR&E#*Leq$AN:u$aU)Q/45``3MV&E#N)b.35(+T%`cQP/.8rv-Jm]P<8xVn8A#c+`%%v29IIaL'=i1Z#,Pqs-iIxs$'?Id)xpl@$otj>$u&%:(hc[)*OK9u$][%@#.n@a+>:VJ:b+B+*ERa*,Mbh#?3E[h(V$v&4:WL7#x8q'#Lc/*#;2B.*,39Z-?;k(vAcd8/u3YD#7n6gL5IUv-1]WF3:.%Q/o$l@$?DXI)`v3j1_`*v%j7l<M(9cOoGD_J'be#nA_)XN1gTF+59b2oALsr)F(f>C+2L#TM-FD<-?npw'h6Ie-]/fiL;V>W-;rSn3vKK+,G12X-UW/I$xltXZmC+=(&7L^>rCF*GW['^#Z]vs-1c:J:Cb%_63`Vx-,q6H3kbm5/w3dS7j%89%[cWp@SFph7(aIk0t71%6fO]'Axljp%F6_'AC(S'&)v2P0Q%tp^PI?>#]Mb&#rWUX%GCuM(_J(N=oxIY%8=ap.LH7g)8W]t:X2SVM_Gq0MXO6LMsYcA#j*dTMH,0C%FUc]u<_a18QTK?d$*o._9kfi'u2#,2'4SW-rAXg=Z46e4Xb4V/D3Tv-L#[)*w0`.3`Hj?#e/ob47L]s$7*;mQ#6$2)(f>C+IDGj'B^_K(%_sq.<bNt$r,?g`FO.W$j4':&-MiDFmY-W-Cf_w05eTq%Cnjp%]A<a*LOes$W$E`%vl)B40-vn&;Sr&0&&>uu29wK#Uq#-.bepY?5v`'mjifF4?DXI),g.(>e<?`c-RZd3xLGN%;ccYuMJg9Mk;%Ec4HNf<wiJfF2;uZM5$oU.Ou,?8Ym2]$I)5uuwng9Dr.+)*wgj;-U^U)&h#sAR6?f5/kL4I)?]d8//UX,2Q0^u.[SOl(-=Vs?643v#>73.+vZ2($4Sc>#d4n8%e0M?#^&'58mEUa#N%QZ#;c1?#BWC%0Jg4',2b'T%F7KU@QoU@#=#>J_r]`Y5V];MKX8#:8SI2f#dENZ#)7E9'M=DmLdMdo/j79p7.2r508f3>5ZvFm8:>Fa?]Qo)<&,>)4cUP/+Y)E.3[6g,;_nls.dU<9/<ko6a:h^7)GbR[#qn]_#pqP[-Ng>o/>D34':VN-)v3&[uF#5[&UeQs0aFFGMGMUB)NMZp%.VN/2SO>gLMwO/2_uQ[-?eK-)b9=6)[#J1CZP,sePMM8Ir>=KNCip9vhaKs-?KNjLMuPA#iHX,2si:9/d/Z%-b-ikL0NC(4g_(f)Unn8%/U&s$ZVd8/Qo5Z#Rg53'0fb(/nAGb%QB0Or7rMDFs]Zn&oU:AFw=Q=lb-A<$[;Vo&.J^V-prA'+<VH),6P>(OIa3I)Bm-h()j/tu^8e.M%]bA#5>Q%bab@`aA($##BR(f)04vr-SrU%6378C#+<>x6Tp1T%2$:u$)jKb(qkcj%Rtld3'cw<$kWi4%,`tS7:#oL([r/F*3Gjf4:'r;$r[Pp4)MtrLF[FD<s.vG*VAPkk:+Js-Z=D2MNkXI)t;Nq-r_-thdc``365QhJNw1IN@XM@6m@Q,*b3Ltu%*3G<_n4W_G)572b*'d+dVRE3tL?7&P?NM<aU@`aoLCj17X,+-*4Lw%YY7^,9SMi4`Ej?#us`a4]qIW-P'WNt<jH.26Ys#-a'%],6m8c$Zb.W-l$9]AEJp.*dh%H>N3$-3W8`I2)-*?%J<5N'#fhe*HD*s%LvC*3Un7C+1(pq/r](=QRAOt&OqcgL7oh&PwQDJ)j150LRIrO)=/fL2eLBq%EA`v>;?l%lEfKB%Ed.S'Qvw*NemCo0IX.'5WrxL(/,VPMTd-n&>$CL3HKEV7dD24'Y#pR.sERv,YPxfL,`HL2Jj./&=/D`aE,W]+f4q'd>`<:)>J/l'ZY?C#c4W/1SZg@#9$v3;63Xa4Z1We$GM>P(b:*B#lnr>P9#Ox%YNbp%v4RT%UV=Z-vI_IMeFI2L-*a*.]Gdp%(b=K1Gsu##l$il%d^?D*+KbG3XsH^6$FH(+@CR9.Q.1+*I7/N0Rp;+3,g^I*fLrM:1.*D#N-h+>vdFK&j9K6&e:X/qi_b@XrN]$Tqd>3'AXQ']uk-F.jJoA8$7u:&>+40(%BO%,=d)J<lb?5/#(/;Nh'5L#u3<)#]=#+#jsgo.^q[s$9$tg**c<9/SP,G4[^<c42Dm++ZZ=n8=N[kX.;XI)WY<MEP[(A21m(u$t'7x,HT^:%`xJ+*2-&W6cdcK+K;aa*Vc*M(*''Z-i[,C+MjY7&HEt=$1bl3+gX%W$cP`.2^#*a*M/jA+K^8',/PPxYVU,N:Y.T'+>oNT%tUeS%5IW5&9JG>#ER@<$iY`K(CFIW$1D7s$cC)Z#f1>Z,8:w8%O)H;%F+M;$fnVv#Nex0Ui=UkLJKdo/)Me3F%xhK&#`Tp7Pr;Q/-]:Z#Uk%<$77e8%:N'$-;fCv#'G:;$8;-`ahuC`aF5sx+w8#,2[>G<-ix*%8VASI*,xr?#V0^u.^nr?#l%AA4mV:a%T9:-<4Y(?#UZ-38(D,x6g^+f68SG>#u3/N0GQ2<%S1q8KvdKh;(e_;&wh.'0fOYHO>[aT%xi9s.kmS5/ObI_S*R8T.bKb&#26T1=:=K-)#XXC&6h'u$eHeF4hlwU/VM/)*-Qdm@Flo>8$^v/E/J[V8o)lP9Dhs`<rTF+55:x),hTsl/wceD*R2u$Mn*EZ@llDC,.+CJ)o.:6(O/Bb.4wWC?o$*%,P@QP/IH1U%.:e+ml.jR#L0`$#-sgo.(ZX58%xqa4B=Yd3d/Z%-8PEo=t(9f3W4:+*kY*E*t-ji0VS0<75Rt9)hX587E:t;]Klm/;D`qd'n9UI)_^,nA2,97;5AiQ&8PC;$Y<&W$KT#n&(9HI4SC&e%4@>i;+rZ`<r##g1^i2@$s_C%,b.t3;L`+2(#I5n&t,Bs$t7=s6K*X9%dPUV$bQ]W-VqpB[4%co7=l5g)hRv.'mYKI*:^]KW,ixu%qi(Q8f@u`4P7@m85+t>-VH-j89XbQ'Y]R5'7@j#lJO^?-wO_t@(f>C+Qfl-$5&h8.pK[k'42Qp.VYe-)'2h$0v>Sd<oLR[-XHB_/FeY4K+JD=-V>uk%:vC`aIv?D*NO$##L8lG395ikb0YbL%-82jT[r^b*$2@<-lnpL(26,W-8&2_J'Mho.xJw]mggdd3=EW.3YiVD3j$+XA<i3^4>,NF3Ls(B#%e>w79)h)3p@%kas(MC,-W9;.W.t3;)Txs&rTL-).K+-V(jvR0.+CJ)(da_$LceC,V?D3(34YgL5Mc70m-54'<T[W&afin#)4TC/LXI%#Q]>lLbY(f)OIR8%*c7C#xE(E#aoOs6rqmp8%Gm;%dcq8gO'(x$c)`h(AL(N(jW1f<j$bQ&9eTA$k5>7;Xl*?-D916&GM9<6+AG>#hAEU.$_*-*GZ-d)Sg2:%EI^lo6p?;/bu2:/;,##9NG1p7j]kA#TSN1?PaM'68dLD3Z'GK.j,-a3$-NZ$mNv)4;AJ*3kPU&5J:?O2]KVX,@J#v,xrKL:me._6B0DG-N%r-4J`psZR:ov$8*1:@n,hN(lTai0d9%##f2NGu?<<Z6uqU%6u.`:%tf``3B-Tv-%EgR/T>%&4HjE.3lYWI)tN%x,Ew.i&B.=+3,g^I*Zq36&W3dr%[EDO'Qx9U@BXw8%LEPN'g=Y#6I<J1M^Qt*,p'3r79S'N(>65U2-aIgLI++G<F?&49MKpQ&YDVO'Q+K>.,GDI$Pb7',7B8N2I0Y[$G&>uuiA3L##;4gLhVB)&:Hg9.gb^=%MZ=W->A=61a2wL29>JE-5lT`$X7.)<=v<_$)Wwb#1co(5V$###//]^.4E3L#H(ix$/TIcM9LI'6FKe>%wLN,<AFA=%$l2Q/@Dn;%YDm;%%VKF*=`<K1'dWI3mZ8x,rrdI243M3;cV/J3a=@8%vfB,3Z)fY%;]Pt3u'^:/v4gv7$7O?#6Rap%boWE*DxbfCYF1%,lhMW-OY1Z#6F3T%oDa=.b]io&PX%@#fInZ$Vk/7/XIrFEuC[l9e'`<LOIoR9Yov98ok$G*/r-W$lDuA#Y/96&-LEs-Z7ofL/?/=-)q0q%=EA>.(L`D+w3n0#]8P:vgQ,/Lg>KM0UZ%2923$5AoUi&J]#2]$DlE<%nO'E3>;gF4,7$`4:*YA#OCr?#gBWq.TL,r&wa*G4Di^F*f-pU/tT%],)Aee20Zc8/Ckc054R7lLG/%E3hWas:hj]s$q;rZ#=:n8%JnP[-fB?5N2QNJMpU>;-.3[)4G--v$J'O9%xkn^=)I9PQ*6bY)Z^x,;#moA%0HB>:j)Dk$QN7)$`K/s$c;sB8)=NZ#nXaT/6)w5/V@.w#(+NZutV4r.4,mA#5?7s&r./P'ZEuI%+f18E%8-/*gq1d*4Xks-a$go7L7dPLhGgi0M*do7*Xbr?o.&c3QvQJ(RWgf1Mnpr6&mnijaZMi/C7.[#a4n8%SEx;-5wm5.a]?+<3M:a4`3I]OB`rU%Ra1rAY*xM-kh`s$>e&m&:^1i1J=t.L:wHC#pW`YP@X39%u*TmA#%:J)E;xfLeYq@Qw+35&DxEX(<_@],OVn'4Dx:?#PMR21V(>Z,XLZP/H52^#,OAk=0r%W$ZlD@$+_BJ%R1w`a&lF@5a$*D+/'.s$Nmxg2?v>V#[Gx+4X<)9/^V%V%2LD=-MRr*%,/7Ks1C=)#Ut/o%KEx;-gVm9%H0oA,uwWD#8%EG%Z;tbN>r5Q8.4AW$Lv(B#mV$0)RubF'?FSxG(f>C+9vGT%iEMc%4&?[GXNXU(>Uh,D.+CJ)ZMpZum)PN9oW+>-dD24'9dSpA_+i/)3so:DI-pW7TC1IVj*[5L&5n0#R)###Cg`S7,NLJ(^c[`*s:p)3eQ=g1IUFb3Xcf)*dZ'u$[e8EF7Q9T7q+gY,d;v3'e?)Q&ObHXJ;K'E<7h3I)nL3GVCRMZuMSKU%X4*p%IXD%&4F=@$s=Id%`c`W%?39A=M[wo%qx8;-p5kl<fEQO(+>3>5-gNcD:j&##Px;9/*Me$6t(V:%k[K+*,LYQ'n8a1FP`@f2$tB:%x3vr-sMYx6B.<9/j5m92@6]I*s`x:/Ab#V/e9_=%bgGj'*o&02]56N',OTfLERv0)F.@x6vxPA#1W$E3FO<w#Be/m&X.VZ#>C*p%Ph+k'K'=p%^BA<$hBtP&>u4R*>&Qb%Zu:?#Oa>j'S7bN.&lepIhhvE=_,Is$VC7w#u+8%$n*ST%*2ffL*?'v-#`SxA`4NP&Cr<S&$H:11L-;?YKwZs0'5/?5F9ej'1IwM0e0a20&*)Y$VN0dO1V^duS<rZ#=(Is$q/;W$7E+q&uj;5(xOXM(5d5K)F@^Y#3x[W-/];p`N^m8Jex,pS]vqJY7NT30&1PN08Kth:th.L_gkpGJ$^CE4[w7j0[(#$GNN=6'D1$##heoD=a_,g)@EEjN`ew[-VKnnA7./@#''nU7np*VhlG6/(e&[guN@6W(btiZuQvMZo'O8Z7qx8;-6sf(%#j.,)sJU`373i.3BQ]4VbYfF4I0>M*w-h%%qa0;(#GrB#&fqkLUenO(M/6<.0;+02+9o),H>0%,E:Ev##65x#TX?s6O5+%,Rx$4&NP+b7XDpY-KM<?8HXr%,SHCE#)C@G;PjZC#]H8[u@l58/jp1E#arVh1rB8_S<uds-%Pj4:,WeA,4f=(.KXcGM6b'E#QE`M%?8#W:E4jU%GW-a3YPjc)oNv)4Nb6&%T#JlfDc4E4)FJ$G[dNdM_'0cVjm@.GM$w%Fb^J#GLliNp>Nds.J/2*)N%TC>tLVI3pmew##3:9%&D.1CIpL7#Y]W-ZnG?`a=-GJ(k?el/6Ynx4o)].*Roax$o:%?7sn,Z,sq-x67k.u-6L7lL_E/[#>ft$%B#MT/=9Nw$Os*W6P`HJ#EDTrLPC->#`i@;/@EWhLZq/GVUiK'+K-wZVk1k3GQGZH2':Vo0F7OF+5<,A#9(^:/j@E<+sowL(xS*C4YRla*w&Mk'3P-:8x;sv%1+@p.A=mc*aDDS/-)'J3@m@d)G]is-+r+gLd>2Dfd5[M0lC:K<axI+5;%d%?^XkA#IGb7/KD9E-rCbpL8WMf<M?TT.d8wK#ovie$@q@.*ilWI)CJ;(=k@^v-?ArB#Sh5<.6Ou)4_;?kM_[8%>E7Q@-1tim;CqtP&vBJ/1)>P>#Vr`_&'mt#J]wV?#e/wS/SOXO'Thi?#jsx1(,BQq(UPwS%ipvSDnh/[6[DVk'hnYg)1SD2:XclQ'7####%&>uuxw#-.0atf*n2GX-s<,wpbf)T/#S*w$m3kt>I,)H*]_hA?dOv;%3.5GMa&V]$tPTB%=r(?#PDs%,2+M/:E3?_$sZr%,_qD/:L)hA=<:.6/R*vA+6Q[JCadkA#thI:.SUxR#G1F',wWfj0w2fvPV_+O40m.l'wYw8%:lOgL+/7aNVAa$#.x#&%'qw.:tj%##e&DQ/TekD#lESP/mhv;-54em%gE(E#qYj/<Fv*0&.X^:/-AEUI+8cR*pW=4Mui<`)8'lq%R#VO'j%O**SJJ&(:$+vM&BSYM^pGcIufWX(d#sx+swoV/aLV*O5h&1_i(-Q'U2jI6IJ(8oj#`]P?Qe]GIEWX(cv;a*KG_s-qexnJ=r:%GG+UiW^[s3QU't.LNgSa+lXZe$3aj4`Q#^k9E/ge$GIGR*n[-UN[1PS7X7/cV5BUYZ@Z*#HIEWX(^Zv%+95c&O1J4+(?pKA&(pj]XMl,QW+PCK-EkZL-qx8;-Xc/s&HX'3)u#9,REl7S@gTX&#[O.S<j%3r%9asDPfG`#(K6JvRY`@Q-V`f48FBwf;Mqge$SFm]O,rJfL-^A;Q?.Z?D_0jrV8Frp70VHT0D'CT&wR::nG9vG*,(jtK+/3f%$Is58%s1?%WnonMg^_%OAVY_$JYPa*sp#<->%(8'$K9V4t'Tu.-vCp.,k*.)dmfe$:a;U)1Fh[m$WbA>jqbKjj+J-)cRrs-MZO59^0@#6S*4c%Px?W-Q8E'H47p.,mFgJ):Tlg$5>;6/W(f],A%,&8e*#]ol.j7#UEX&#gOQt0.uv9.)^B.*-QQA4=Z9,-A.PG-RAjf%%*@?Q$B,%,39][uQ]&$0hFh)NhVnH)UNSV1W..E,>X=Q#a:71(0Ott('Rug(_x:voW[$##%)###k-A`a.Gii'/G&4;8U$&%I<FW-<x5H49+lo7vo?>Qot2<-OBTgLRM-##;j6o#to^%M)O?>#R4r?#7bj-$7]?5/$;Ls-ak4D#:Os?#JC[x6[UiS%T6EigNT</MHY&<R-=U99h3;?%M+)?#T2vR&#Y150P*u31iP$8Rm@051HVPF+T4@s$9BnH):O/m&,Vp84?PMs-[qU/)Ne__#Ylc=l]<0GVHqco7r6[c;N4Fm'P1O.F/lrB#Z:8C#L@Gm'*IH:7KPSIM&(B.*W*6h%^3hfLq'B.*L4Y#5G5@80OlMNT1mJ-)Z6RAIPd^q%o12;.p>AN/KbhJ),a54MviH_uPVx&,)naP2g>751Q3vN'PYEPA+Xn9.W]2Z>_@X9%DjY11grse)j)Qr%tJ)O'48q0MMp8E+:&;C69-pr.Aw0R3iq.%#nbT[%A>FS7'?s8KI[fC#l5MG)*c7C#gc[:/0%eX-/rU%6C3Uq)>/-T.4(7]6;3]Y-dKqE#4G[&4W<X`<^ck=&v0,.2F$<H*rxP=ltxBR+T@Gd3`JqK)n'a;$ERe<$XQj8^VXXA>Q-$S-+x@/1/Y0F*eUPK+JQ$caPVW8&@:FdVC0%u6#,E:/3%BAXhZFP8BI6_#crr4#b[P+#vlUf:=.9v-Q5*Z>mfNX]#vPA#B.i?#+K;<%p>?A4(ibF3Je1T/97Xg;0?i9/%&AA43aZ]4@Dn;%1n8W-cFj$'&'PA#+l1B4F]8a#?4Yj1:/hS.DZ`m1iZha#mqXZ.Al:Z#<R3t$cD`0(KXJ60m$Je4-MjT/XP@h(qkbgL*PAx$K55T8@T6O$^]HW.:L?K)G]7Y.=/%?$&Etq.]gLf%9qEU80JWT/To032/'T2^T-2-M&x(hLebAs$4lrNTp%Wo&4#49%5r-s$f_e0>Z,)9/JlW6'2nM@,2i+6'2[Z_+n3n0#LpoXuNc@JLj)DD*Hcq8.[Xd5/SJeNk%<JLa*vg@#a1F9%kg?'+EnNp%HRMI'Eb*X$?,um%uYDK(K:x9)5P9'+#WCqLKvRiLS'BD6%)###ajF`aEoa`*KF$##QOG87%`JD*]sFA#gu<<9Zc0d4:il>#QY/^+wa7I*qE*e'TRnW$ZB?8bSQ^6&qgWe$a<r($It<t$_hnW$uTR1(j9Ed$gr@5'e_^)lgjmg1%&P:vi>*L#``''#f1)mL%qX/2iFU%6w(ZA#D?_H%,-I7_NaWR8/0`T/F:S_#hsB:%ia@gLu4-J*ooq6&;'hA#euiW%*p?j[C_39%MJYe$:`e5Mb%tBK>lNL`s8^;.&aIO+ekcE*DC*wG9]am&1nk@A(BX2M^cwH`lMa=.5q+N'UH49%j5w)*[3n0#O6oO9MlTN(i?*20oq_f:Dm7$nmcE.3T``)3qGUv-[YWI)v:-x6h?%lLw:f)*P(.qBeYxU947GF%)tRkL/K]X-ZZAG;fPDO'KG]iLeUblA_`:N<)l/g1@X:Q(=Kp7/Y]*I)gns,<EeL&lkfWrZsBb2i59[g).Bg;.MOTfL0AvJCb'@['w-bKX2#%&4%8o]47x;m86J5qV6^WI)''p8%t>tZ#(L%g:)m@O;[349%QBGN'/Q[IM6(b31sX0K26^;V9DGeg1W-ZO'I[Ep%Q<OU($j11'e)tL#N;fv5C_39%<3mA4-H_s-j_*j3()$',sM?I2=uLU'OF@s$8U>^XK8v##$&>uu=?%C8=CNp^G+ws.gc``3#-Xd*/+/<-9g80%(Fa&)jaBD3Y-&<-%a/0%7B0ZeH38G;eP6dbdmA%#+kP]4'(1o<I>KUD^m9U.+eff11xS0%lPV3'TY/^+#H<ga$^%N8paOq&t3ts8ktuZ,-fT58Q3F9.(AP##;W8a#%,[0#Www%#hQk&#m,>>#^`WI)1heX-wf``3h6#ZKi>lX$o.OF3*.?Z$3&IF<O[P8/>=@#P9['/LCOIW$muiILdDDO'0DXS7Mia1BR,:L#W#xd#PEIN':Wb.$ES/a#N9'U%_b,jBn.7],r%o5'LRFHVPshl/k)pg+C_ws$.svV?66,HNw[w%4Ncme`1QN9`ZPC5)QQjL):2Gf*9)?<-*1Zt&PrU%6378C#Al$],34p_4]sHd)<r-J',gRf<j7m%&Q+=[$Xe39%[GWa*CmtN0DeX<%0iJh(]i&b*/l+b*$Zhp.vc*I)$taUKE4W9/GSNNM,%Os%V9l204Fe>#S$<Z#UXcr^AG,L#8/4&#v,_'#<,3)#e,>>#t(4I)x,Tv-aGUv-)S5W-n4F=]jYE.3ont[$UB:a#Dp@)*7F;8.<j8W6mvj?#W;f+4:WPA#Y0tq%E:Is$`4*/s>#c1)+2r_&FJ+%ta2Qn&-BJ],0F7E+_]%12KrblA#Y>v,t/PA#,Z:c%)TB%MAwB2'@^n)*,(9h(Q>N5C4<R-)pkaOopd8V.JTF+5:sLc5WWxw#Hg&w#;8:pp-6Rr#'SuTacUKL%.1U]uj8TdR=N@%bUp)?7>8#L#xZu##bWt&#<>N)#F4Xc2%M4I):2Cv-gx[B7Cb7w@FHbr.<2h[6X:Z$0<4cA#$9.h%</a9)QrbF'VSA.&ElZp%+F2W%v_Nh#+q=b%e,GT%XiLT%.9[M0f/Yp%]t79%;$U+MetN'kWXml%6L=U%FJr;?5LTJD'l0B#Nq'H2m0qQa[+l+DG]'n'qneu>K:H]FP#$:.SB:a#7Brg1;@'E##5NT/dxrB#+3KYG*o@U/`7%s$'Y0f)PJ))3>Q=r7jA@`&OdFH3.+llAZJQ*n`m=<QN*F9%$Y]t%Rp5;%?e8m&Q)rK(C%@j(XwD=-eS^W$?aGa<.%%m/#uMT%=72?#Fg@F%?Kh?'l-`k%Wgcj'PF@w#>1.<$<[E9%0N]'/aO%@#M<V8*(-:U%FPnh#s)mG2$&###OZ>YcuI@D3l>,<.;PZT%nH'R):;Uv-27eq$`C3(&,w)a4:N.)*8mB@0Kc>_B.KH-mJTjx%amT6&sLj$'6ZGwe&i'B#pMn,MOD5f*&,@3qoxU<-eH/x&Va,3'2kJWQ,rJfLaBnuu-HUn#ED[8#U'+&#v2h'#l$(,)jRHM97c;w$^tn8%;Ve]49em;^/LMq'_'6(Q`cEc<<5Wk'II3LDdv2k'CPl.)_cQb<a_*g5/e)C(Iowe+sYT&,?./N0)%hm:<g2'MG=?C+:Hg;-OGg;-Jo2g:[4_B#0C)4#TEX&#ONB5)4&_->Vf]gSgPj.3)_Aj0$F&P@JU9+0rxppAC_39%.w9H2dD24'P`e2Nq-f:5gB59%vS4Z-(oJ$K5Uwu#k%CkFJ;<JLRgXkMfTQnA%g3^,qoYb%cXcI)S(Ls-X7Yd3o0`.3ln5E4B/K;-_ajJ1M8;6&5sIB+WQ96&kS,F%DZ&KMfag$Njw3'MWN`iLSmR.MEk1HM^2XR%HgU`3JEUn/.T/i)?w<u-[Q5<%`J))3[PYs';Wk;--M2i/fSEl7Y$FtAD<w<(qLYGMJb>n*U626/O2kV7kH3,NF#b'Oin;;$6)L(aj:@]bsop;-GO>W%=aiY%&Ur<%@p*P(X5ZA#I[*.NFH3R87,nY6aY0L&;RqB#aK[h(7_B]$BxlLMQn@^PM5E/q>tWJ1F)Up%V>`8&710O1]j/.$.(lA#mZDX-&#^jVDMc)%F####/YEf%+jOV-(N#,2>:KV6Z8t+;8<.J3Fmf(%oPMKEK+Xj.t<7f3`us/%[o[:/vu/+*q?$>%q2xb4HpJY(-h'u$c3rI3VHX>-wi*.)%f)EI[hR[-)Qk.)8H%_u]^vG*t70F*bvJsA@0i0O&hR@)[SU@-g#Kg1Iq?I2SEx7/u^5/(6w<mL2%iT7AZ3F*cVj`FTt]5j'Ym_F:5$@0%0,%#xooXuw>),Me1W]4@8d,*(C@G;8;mpM>Q(V%Rq_F*YRr8%G65R&DNI%%b[MB6BqW9%c's(,Bta9%R[?lL5r:T.bA;>$CX,hL9[=89L-mA#9D#W-lxm34Q54'+i9%C%94@s$]G-LMK(%%-E;nS%#%0#(rRn92<;w/1:WL7#8%T*#w1M:%Z,,d$VEW@,*]4N(#6MG)o0ow@_&aa4fFuw5?3lD#0:WKV9i14'1do$5GI`.Nv=DSIdD24'k)0s$S,.?&s#1C0wKP>#Mv.>-YkV=-GS3^-9/4c7WXC*[slRfL;-La#OSj)#bq7o8mwkL:McO)StE6^#sjwI-wCg;-/@15N'xSfL9bwuLU=u]%lQ8/$31wQNeaqR#:WL7#4kP]4ROuM%?v]iL1OUv-S9`$Y1EqpRY6kV74=JT'm`-aPdO(D&hvv%+&jca4e<%##05Hf*p.<ZG0f/[6?-YD#UsZ]4-[w9.0=8<-(UNJ'dVG5V%fo-)s[g@%H7Z_%;'?gLuTe_'j#BmAml-['=S^U%0tC]$6qL-)eZv*lXx?%bc4o+M.j:T7Fp]W7t<HxO9nBm/`E'7&?0T]t3jXkL2UZIqY#mV7QPfd2CXI%#BE^:%'W6C#iHq=%cAUVKEq4D#nZ&'7CR5R&6t3u6:6#^&7=1V&EQ^O0hG=0(ta#p^%_*mLEO`X-Km/q'6X'/LDZ=8%S%PV-Wk$##^EZd3UDjc)%P,W-upJ3kvnn8%P'(02uw-x6Ofk1)MK0.;0=Tk1`i4c42.$faNgSa+TIr-$:T&a+UP?nCpGFe3u[.),Kv?I2i/[03_a<M27QO',6L$H3JK2E4Xf2rm'-(<-k)'://c@<$n0P0LdRL<-;*n68THEh)d6KQ&n`%[#^S[#%hG?`a*gu(3^'%##V5/.M'M]s$h)iO'85Z(&5:Jm/#T0<7ZQlj1mF^/&l,Mg1<TGT*)Rfw#3VL;$iWB=8cho-<=@wo%@$Z-3*T39/>WZ`Mn'A`ahVDs77Q7-)u.@W$S)7>%Kog58g3-v?JI[$M2^VS@WOx*+p##,2nW%##O;gF4NIqhLsT+<30Zc8/mEnb4SiWI)fwbF3J$vI<HqcG*u-AT.Te_F*Xo[Q-Umhh.BS7C#;wHm16'PA#T0e)*`Y[p%GqQvLtU-C#<XA_u+IWxJbVLV.SGL/33,]p%-De21dXd>#:t=/(?*uf(l@FM(?3cJ(3O[Q/YbYp%p6Z]4P9e9SGwFk.IDg[6pwbO-=t8F%E#-'&Pc.j1rro@#1l-s$e1K'+j=+gLYhZY#.)Q%b[PC`aq>:D3u1)T.@f)T/3YafL3u7C#x9%J3;aGx#OV>c4,Vg>5;JjD#DfWF3nsfX-vJrr?DF9=%<g]],tKOh#Klaw$D,BE++`7@#V2c,Mq$&-)#Lhv%Kof_1S&iK(ae)@#JGP&%uM+1#^#@s?'@Gk'j]O>#bqO-)h;GBc,PC;$EkJ##NM7+M=FetLJDE$#dWt&#[JsI3.)`m/Q_v,*:2Cv-:A-L-h6%;7BKc8/chq2)=F82'tt1]tPh`?uj.HR&>Y.@#N2ep.l6/W-P-Wh,w_`?#rKxH(MqP0L]Y]u,$wYIq2jW(#&5>##[*Zr#p@)4#Q3=&#f$(,)PxeA=ZH)c<Lia.b+Eu@7`umB=&;G4KRhkA#=VV=-wIg;-_5[UM;M>s-a.hDN2,L8OsAL-%d=#RNnB3eQeFNP&<?.S[-C)##JI3Q/cSafL>;2)3vbLs-dreA4jS[]4Ze75/s?id*U@Ua*>VggL&RJq.`M.)*Bx4b@wcE_&EIg#(=wOw9r.7.-3wtkO8FiHQ9>F_1IR?wLw1K;-cmbo$lwrY#hq.W$VSS#,5'ct$@IRs$7Vp;-14;t-iS+JMQ>b+NQF6hMLqq`Nb6]Y-SD#C/g;&Z$I.roS[>(5pcU+p8)T.5^wXtA#d]H$^7%<s$qsRf-_o$:jK`/kXO0XT.(?$(#85*Y$:^KN9fNc)4#&AA4Aa1q.ekj=.NkLx5;60[6+FYI)RJ))3[J64&M%VDN?*ht%>qCJ)'-9G3CTH=L/;64'-7K-):m^snG%v7(C_39%IghA4fwXg1W5+%,W>Fx%(l2sf_?L-)-fs/Os[?>#8GQ%bj%D`aLcDV?=IXQ'%e75/BTX`</(*Z6x*e(dC&]iLu]O`#RjCv#rRwW$bIvQ8X@Xm'w`Lm&Fjs@$;Ze97jEt?#D]<t$NpLv#Ubjp%>e?A/8F7<$u7xfLoWAw#x@)D+f3n0#L,###%qQP8Mb6<%Qg<J:0l&Y%'::>?(/K02X4K+*h)iO'a-eERa=s;7@9Gj'nc'k1E%AA4'&sD3oHF;.9t_F*;qZv$xh$lLnK;BmV5do/-H1q%l1XE*YKuJ(v#I)*eb,G*G*tP&8wYj'UOe8%bD-V%btQt-T&2K(O6b9%>g1q%5QWm/%)fv5d5qq%1K?PJ>C)s[CGu?08p8'+b/nU&[NdE*86xg:Dc$-+;?K<$P6'q%U>qS'[Owo%1]1v#8voA,'7-01AG+<6dSv7&aPYY#r)gs-]i`,<aCtY-K<#Q/+d%H)MDD)3eK+W-]9KsBQ%`r.*qjxFdB49%^$]p%xFKP8(f>C+>Pd),K0LG)WEOV.kQo&,K']u-ZEDZ<O3X6)xil&#w=_[IWSo/1AS<+3?_#V/mh1.3HK7l1%e75/Tl4Z,Kh%s$::tD#DMn;%SK0#$N)b.3m9T01d7r?#`xJ+*m$Cx$rO3#.BA$vLPPwtLifQ>#4cY>#)nj`<ncC_&Y'jV$MTZ#YG_Rs$rt*^#1x?s$I^$d)-QUs$4=3T%/v^s$5(V?#7='L5tq>0Fi6I;'Xh%[#>=@s$Edd`*aXbGMk5up%=;P/(%A%$$eF+gLtAF&+/WE9%[(SfL&hF9%e:+,M<0Cq%(CEJ1%&>uu'b/E#[GX&#tG)%A?q0a#PDRv$R8o-#Ygc[$3ctM(3SAk0f/Yp%0==I%BTF+52kis%<`5##AR`X-5e[e$iO?(%THcHV93dr/?w2u$Sd7dubk5=N28[;%;&O0P]aqR#sCO&#h6fT%,t$)*b[18.J')58nW%##6HvA4WQl8/Pab^,HmNv68Fn8%eSU7/v3q_4hEFg1x-lI)[(KF*J,>D%nGo>Se;1u$lb3W-vW=E,EIpr6gZsZ#*h'm&`DZ5&[D6C#;x[w'Y70O1KTJG;iqO,Mi3SO&@Blj'gM%F0gu`B#@fIVUs)k>-#qP-)f[7'3I>U?-G_i[,s?Hg)5`K>,*Zjs)pPu^,>>EX(Mq8X$wcL6&VpcN'u>f&43,2G+J,97;N8oReNPbi('>cuu6W_R#nw$8#d,_'#u:w0#NqXF3Ls6N'[KA8%Vq'E#*3=L#nB9u$%O]s$RXp+M+)>c4V(.x6gNR1Mex;9/bvY11Q94Q/Jc7C#3v+G4TD#W-^t%F.,uME4e/ob4:'PA#--6^,9bnBn.2o#/E35N'kpj2MTJ]n1vrS5B%/AL(rtat$:Q16&nlH3'9:7<$RHO5&6+ov$'UvO(ka]@#4xUZ#7XA2'J<%$,YvGr%X$&w#1Y(Z#9(rv#J17W$wh+gL(lWk'JvZ)*PLE5&j>H7&oSVk'^s9u$3rhv#4sqV%_.%w#7x-W$3>oe4SM6S/n%p/LZRd5/VsS#G3>G>#6>'^%`Dvv$dDlB&A@rT.+PC;$[l?x-dL4gLTnDv#Vu[fLl@xD*c8.L(o`ed)C5/F-hqT4.hqTdMp'>X$TD.l'-+3eH.BH7&q]r0(_#Cu$cV4%$LhXVdb3dr/.Eg%#%2Puu$l:p.%,[0#U[P7AR7902i_Z=7='(]$@>8N+gJHd+20p[uv;3RS5$2<)Ebvu6:W<**b@D#7,Gp;-MmG-2:$Wa+dm]r.FfFB++U*[u<ssq2F####dRUL&S5R]4#U^o@'dT8%e?EJ:9bo=%jvBu$7btD#9RJw#nEZd3*^B.*c^7b'NEC;gOINT/'TID*ujDE4(65x6#u>,'ZgDB#rj*.)n*<I$xFoA4UUB?5W>2m&(:l,M^)A=-K,+i,7'C0c]#AiL0YtU0UbdO(gv<A%REeL,mRh9Nh/p03ii@n&_#@I<_Hg6&T'Tu.iSI>Ors5/(R=S*+_<2W/BMGn(^ME?OcCZY#D$feaYTb%b:xju5K(_8.s^v)4.tBiD^wJ,3h'of$4c^F*/LaMk.uf^$:&'f)lh)Q/xVY8/VMi=.DW(ejTxAc3p$Xp%eP)N0,0BR/OHgQ&H+ZLMA8_j0GO*bj]c,##)33oA9_vH3e8iOTY/?v$-S>s-^G:hL0ZFkL_n8g1fDj*4La5AuHK3-*:l.':<[idaguC`aG2W]+2.co7kusY-_RVH3<H7g)jAqB#GIpv-Ut;8.r0'oSfj&E#Mc%[u9#V<-:$Wa+9(Tu.oxBvdhVnH)[XQ@)uRI(MD5`O-MR#7*3Qwf;Su?)E8l(e3Vpw.:'[BS@<;?E,eLb@8TnV78c)1@K*p)^=-F5s..%n;-t9Ee*xcm20*vUv-[5MG)^*>X(q&e8/lD;[A5k+SnEGG],.3-;gVXiG+wOk.)TrL-)XYJVM-;Y+H1+lA#o.km-_&+5(K99U%AA]'8%CHr@5$XW-t7rgXd'Iuu;m6o#<WL7#Nsgo.Zk[s$L$e,*0g5F%g4NT/Ilo^f4n&s$hoCa4+)i;.ST,T.]q[P/B_kY$(ZRD*fEGH2%[*G49BL>$Je$u6q1'J3Q&5-4Ppd)*.@sp%f2mp%>.R8%3`1v#2=*bRAAr#$hBxT%^bAm&fkrB6,8I21#X/w#6MP>#pSD`-ge.<$FC<p%wwqW-O+N?#h1Ca##EO',lLX,)oIfL(9`l>#=?DZ%=FOS&9XWp%AdeiL)(qN(ru@A.8l-s$:7E5&k7Z>#S2J6'F<Y/(>0$_-k5l405]_V$ah?9.4qkdX'rQ.1;4>>#NH.%#K,>>#^YLW-t`ur'iD(Y$Z7A%'7N.)*[(Ls-,(*9%l<5H)63'9%d23Z5H(-H))#0;Gn.E[$Z2@rSgToJ1fRKQ$q$:hLo;ojLW?VhLL2L#G`8=sQ-xOK1Q)%VSfO=U&/'7?/R::xt&e_S7Q7FD*PU$##kX6w&wg;E4,MhkL:^=.)806T%OrXF3;X^:/vBo8%1CI>#&*$V%DcnL(r&)n&`W0V(O_9raD;.D6Phq/)%>l(5IFl6'lJ#7([$FT%sS7KYxI&p&rSLlfYG`l).eLf<b&)l0Z/5##+LQ_#O*[0#fpB'#C9OA#o#D</:7(&(kxRD=?4$HF=ae8@CXVs%91wAMnO>V-*.UB#>570>j9;-)NZew'?OG]u-S+01'>cuu5HUn#F&.8#A;Y4/@>N)#cO/$pk6#j'ZY?C#0e/.$5W8f3MPsD#d/Z%-1deiLil7gW^u9)(ec?S%sYV,)[BhW/,MRk044G**A'^M'+>X2(XErP0K:;X-_iEMj0g4ZMU3$c0[UGE*sbp/)Nm$d)IA$k0ASVQ&_M0q'9S&:)B<*/M'R7@)+gDAPa&<;R7'<dMmvm>#bMb&#,WH(#;>]./7QCD3C+-F>KS.i.`<3:.R(+f/jEaf:&V?(jUNsca#J/9a/[g34Z<K;`Q)###;w;##R@b`*d57;^%1qb*3E:N0)^B.*[KPJ(QeDd*BiI6/SrU%6[P'o8EL@q/vh=:&ko,J'DbfCM)1K9&$=LdM<r@QMQ90O05A?6)1/G>#Ph3$MM7-##T#4)#+;###qk&/L>xii'f*IP/@L,87u<'8@sITqTbdm;^5'RK)8o[Z6/xrB#jQ-+WDRw7tG9P5rEVpu@+(1B#$wIl%_0aVnB&Z#>U&;,%+h49%3q'HMRG1@-^p7f0dD24'DsH-)YLX,M>*Aw@Kpcq;UWjJ2Bl?2ME^$TMrKUp&<O*20*JE@./;ZA#R8-,2EHuD#h'Gj'*RPQ'Kq@8%]9VcD<dLa4;ZIl1AB]u-RIqhL/=2DfhYsf1F@2K(h3r%,7=3T%*Ej+NmaAW$(h/k3u'^:/6c6;%wj2^OnWfd;D'3v6E*7?$<iu>#TMLw-^6rxL1FZd3^#e.N=+As$^BIa3&5>##9^$o#:WL7#lOj)#;sgo.P@i?#ma<c4#0Tv-a7%s$T>%&4$fNT/kK(E#Hi^F*i'Wl%&xn8%x3uJ2>Sf)*KG>c4BA^Y,jvw9KSbqJ#,T*?#Pp<c4_n/J;maN.3VwoS%'4Dj9b@;v#Zg0q%@g*t&E)kr&3'EI38O=?.WCT*-Z)qu$?/s.)w;4ID#LGT%X?ST((2bA-u*j@#lYrY59'Rv$K*9U%#PRtH]W.'5]IU+*[PJ<?`=m12Jbn<$rn`2rn4Xv%%*p(<:E-)*]3B:%3p4o$.Wub%n=q,N-TP8/)<>x6Mf^I*KjE.3oi&f)$q')3FH7l1XN]s$CY@C#OY`;7BUU+AX&s7[4]pH)$nnlLdrxf3;7Ha3,gfG=)QXc4NJEp%::R8%Xscp)5h3d$>XEp%:1*I+DWq/5<)aE,K>2@-ZkuN'aL;[#9mu8.jdQ9IA9?kC0.[k,vq%[#)KT8%xshT0.JYa+WKXt$SJ=gLgNJW$?O@E+(#6_F-XH_#ZA)4#DR@%#nvK'#53/T_cvd12X[L#5de=+3WF;8.[=@8%-2rv-jL0+*6-8u6tSH*MJ9L+*=3UxL%xlse7=Y%5So$j)lu7v$,DK'+,CQH-3@Zd3.NS^50.<G+Aiu>#Zfqea+A;I$oA-G,E<46/+S89&d5`G)j5;4'o#;v#AY29/t`1%,#P89&K[))+i:gl8$)tY-.FHv$L;cr$c35N'^kc*v$M>c4jA5##k]01=:]pYC]PG;7DmoDE]:<`#Mr$r8PR781&=MNFdYwe2drU;$s,un%Q4jw-jr]l1RxP##]B1d2g5wK#J6i$#jpB'#*Ur,#_)fLCl]u)4/rU%6&-i$%i.Gg&O5)T/qw2aE85Im0JG-^=O=Sj0;#K+*%Q3.3w0`.37(XD#;X^:/7=V@,ZDsI3[/Cf'#nb6&@JVN'OJB]V6k8W-[?Gb%mXkL%ik'R'`8Qv$Lt]m&C_39%XQb=$MwjP&:LwS%Cw/m&[0_q)`xgLC'DLB#T#J0:[DNa*KpX#5;BCg(s-hN(&Hcp%Xs1O'*UE?#GURs$EI7q.LBt5&^ZsO9+F@ktGK>G2;?#0)VMrB#Sd,6/lNXA#8JEuRu$^[%+thv%ZTXp%*iET%F`*X$/jAf.8M3H)8ZEf/DDBmA+t8A=q2f%$9DH%b.tA`aBa?D*Vh$##<kY)4$YvNF1v.l'8BNZ64'tN0/,-J*8O1x5f_gb*v_ngL_.Vv-kCs.Lf]<9%Tdf*'U$1H)jGD:%nO;9%4i+`%@XHaN:$;?#d8,8.)qB%MGR/N-kH6&18>?aNSQ^6&cRWN'Q@R2LxI^l8Dvlca;fcERa6cf(/c`#S@]Rb6B[kD#e2p_OawTN(u3YD#A]IrL*sZ.qf$o5&H'^GtNv-tLp3/f./Gl;d1jKk$d&$6&:[&NLHvfI_0XkcNkk*pAtH-B#q-ugLXsJfLIZI%bf=hERfCjl&lNEM0Fq(58vp%##akY)4_c#E8hBTBH`L6m%U9Fp.:[Yca.?Ox^Hn3X-'%:gaaG%#%:D`p%Qj#WSZONmUR(It$c&B_?W39%'q&<A+&Zu(3;m&##2UOg8U#?g)tQQ?gP^,,2ZP0'd1VFd0=0BC)6C/q.<:6V%`VB3a,de`*<P;R8Qfv??K99U%jN2W#l8ig(Sv*q_sf-V%2L5R**I.hLx(9r0;Fhl83#[#6^G9G;PN^U.+cQP/t)'d'cYDD39*4R%+B-N0WI;8.)^B.*c47V8q2bsSSS4t&9p'Z-TSJ4;@n#0)=$_Q&:FD=-?M>s-/<[iLX@wT2hw7>-S(pc$`/X#&$iCK&#aT%MGO:j(3Lc&>eh&K2a_cgLY:mZ,-H5F%eCas-<9HN'I=O/L>vf##'/###'n$p7rXW]4ST%29sg%##h7LP8Jom;%nOBBH)TPA#w0`.3ljEZ3*>`:%@xbI)<X_a4(Ox*ju-,0LI]_W-^eHHF#<Y=$;$D?Yh:sqAH4>C9K-x8%Q.8;%d/)S&s9Iq$dU%T.%F-G#=V6u'dBlj',mAKM[1dAWc73o%>7J89pX?-3Ze75/[7%s$?Ja+M_PSF44A3S9,n/s7MQo;-L#`a%Jm^,(p&I0YSHRX)?;1W$Id1E%.r4b#Yh6##:d-o#A,78#a^''#,x%6M9e'E#(ql[$F)b.3V_=V/lLbI)&Y@C#hi%6/,J64&x>Uc<B+v%,F2/n&Q>VZ>M3dr%9P616?JP_+r<.V'?3,)MPkX:,9#tc<JasS&Kj8p&KaWs%kSx0ME1Yi(r9r:',>Mq%_C;mL*#*$#OA#1MaF`hLdXv)4#L(E#.1v^#jV3E4*$u9%^qA3L9*_r._n-U7W7#uVXkvuu:m6o#=d_7#^2h'#lNi,##:K2#LfB.*[q[s$qaVa4Ap+c4'W$@')fZP/9gH['a`$w-1+m<-8?T01ofY^,H,wD*c/VO'Mj%jL0vmX.x=XI)GsYh1FE#w-`S6C#w<C]$;'r-M_N8f3V%A['@@[P/oU65/JXV8.7L>w.[hi?#rW0bIZ$UfLiKxI*m;](sgr+v,Tm,R&]YRD*DQul&?*Bq%EbaP&wKH(+S=7[#T[iZ#oAru5.>.s$M:WP&(ZhV%VQG>#'vlU;CTu>#SK53'-DG>#%#'1(M-'Q&Wjlf(K996&CLaP&BU<9%Z6s;$X?Bm&].jp/[EWD5<[*t$<C`?#AUH+-=bRwdr)8MFhNIdDO9SH#xo/4;9x1?#1h`j9N3cA#G8JO;KBP/(;xo90DmI-)f(_w6^qDI-J**D5+JBZ56e1@%GK6Y%Ch4/(+lYc4$Q(Z#T-J[#@v(21SNKq%'?MK(-`hV$Hb9H)KQCK(omTq%Al8G=RX*t$cZehCrD7/(kL$##$&5uu0(YS7Gt^`*c<i>5fvUO';]d8/(`d5/[j:9/ccor6M&SF4Qa5>'mRWD#<Af^7k6f8B(0+A/Eue[#l/VG)qYh&G6@Dk'AR39%[1><00((G3?0iS0,+B6&kfWQ&(]Y?6ohl$G1QO&#9A[-d*)2'#wiKS.eEls%.cLs-MsjOBg^gJ)mXbv-w#;o05'+[&S]_O)+WS0&rQ6mQf')p<3RpQ0>So0(FM1hLQ0rP0F6UPNALI&Mq92Df9Ib'/*Ia>-]3u?-`x3_$a#//&67IP/[j4<-_*%*.7X+0;3Gdv$.)b.3RIqGMqXmoNw:+.)Qv13'/])a,./V#$l;Ud2nkBU)/i6.4M+UKM6*r6$vjau-j>qq%r9$eM7pQ63vc+:vBXu>#PZI%#?,>>#p&VF=[4E<%(9lA#&:5G=lGKkh]?f@#RoFh:1AMC#D4QthhUJn$IY$F(X#vG2g%to7um5,EV`bZ$u3YD#jMS1t[Bs?#+x$m/lf/+*[m5%-$VGs-:tUhL5c@C#B4vr-SSH,*^OWH*3%I=7sO,G4.SNh#cc``3J`,#BHdMm$rx>)4amdA4xd89%-'>)6Sj5V%9.7s$Mh39%aAxfLZd=9%m@sw$A%Pg1Rp_k'6LdG*TbNT%SN0U%Mhe<$+GcY#IL39%E$^2'6x_v#0i_;$Boh;$*(_p7D;wn9k,@G=Q3Xp%<ol>#:CR<$aOwK>w$Km&;%2v#P5nd)tCkE*qox>,csGn&e)o?9gCDv#P[&Q&mw*L);fP>#6:7w#;XW5&dF8a&X><PAMFfv.fY]+4+V9O.)E6C#>r>dMfQXD#'em3+^Z862gFH=7+(vW-AhJe$rsHd)nY?C#^7^F*rRoPDnPGA#n&PA#b(1H4dl+G4K7X-?(O]s$MT$H)1(`s/GJ-j:Q9Bq%8xJ)*Ra#R&Tg9#$9OEp%3(7W$97r?#5rL;$fd1g%f(r;$>I[W$c`ro&_YNa*WmQr%E$pi'vOF2(EF`?#a*/@#0`Lv#bErc)MNL,)BtNX$hhi8.'824'3]9_#QxUv#@UN5&^L=gLeSYA#]woE@-1Q&ObsZC#Bwjp%D/ul9l90q%C'kp%q'7=-dC(w,'<P,2>F%<$L_]j'8:Fw$Os,v$ZvGV%w9WpB21x(#paWv%5nGi;P,*Z6UDDMsO2&n$qaD.3Z3f.*IKf;-(LMiLg/E.3p:H_/`'Fp.e$Aj0`Q3QLL4`e$.J_G3&l2W-*kWw9[H,T%w`6@#1`hV$B*KQ&'#?%-dPK,$+XU,)GmQD*>On8%<1Is$::e8%CmGm&2oUv#,P(v#0f$s$9@7w#B=2v#`_/m&:1`Z#A=;v#HbwW$DR@W$Z5R>%)Ye]#+wa)<9f:Z#`l79&bi'L('&OB#g2lp%kq0dM7pRk*==7w#:(Dv#CXA2'<II[#<@.s$>O&m&](SfLdIKC-qx8;-QEh9&'b_c)bOPV-rZ*20,gYc2@@KV6^At+;(nop.OlXI)Rs'g4o0Jr8I^Sq)C56g)jbLm8Tv=R*6)TF4$/h;-Fo`Y$wtC0)M6#3'.7?C+C.^(4$wl'G=8%a+A#_/)JUi0,6R*61pL/FMcwd1M;]#WMn>].0i1`i#Crk-MPO8d%[)FjLQ&;'#JSTd'drILc<-F1W-]EJ%#wRF4i@=<%Cx;9/`xJ+*l-qA#g0Te>2RFqA<`82'#E6<2:ou>#ePtJ-^ISrL<H</1xZ't%PdCk'9Lws$wK[a.[Kb&#3Hls1l&e)*e/ob43fNT/TQE#PL+.URoteo':bNt$t5,+%-.0A'F,;&T;XnX-m?kp%.JO]um)x_9$J2H*2S3>5S/]X.gj-H)Z%AA46N.)*#5NT/ed3j1)IWM-Pd$Y%MX8<.>_N5&l5:q%6ccY#Q$=]']eAQ&7a&cNb4-3'9&Rg1s=I;%R`j**R:Mv#R_`aO#P=**GlcYu/kmQ5c3EQ/(PUV$A7xUd5>d%bKJ8>,<Lco7a8Vq)#Ov)4L)b.3$DXI)lH@lL'UMs-<)'J32K@d)VF%BP4@Zp5`xJ+*EU;',YlLZ#<NLQ&)*;mQOK`$7Q(@bYum+[$m9)/)xK<v#lO1=6F6=1DQfcw.8.%X-r)6Im/7d]O3NE?PYX9`$AhsT.dd0'#SA/,&/T[)*C:H:7RbNT/`Cr?#2<^5U.8PmB_wCT/h$5N'Fvb?-/mbo$n%&N'.9OZ#]&r0(O@)Z#gJ9fDAgD*3T*+X$Pagq%Hp)a*V3+=$.Yp58x.?%-e22g(-j8q'T*cJ(>lL;$mYW48>;p<R[#Lq%6JlY#KnI[#(h(hLFfv.:?Em,*xGYc2Bm<Z$X$A$Ta@AC#HK7l1K&ID*0YX?gV:AC#UrF(fDGtC#D-0a<bL:W-UC3T%^H/Z-;QBa<28L>?M_12_94%P1hgXG2h?Wm/_Fns$cW]n/hn3X$dX`X-WqiX_Y'sr$8A6`a>SZ%bEj?D*9%0;6s0br?F]tr-CV>c4aIcI)dT')3ETG#>J^CE4R.q.*I&lp8>K)<%KfSD*KSQ,*cPWb0S^pf1JKOA#scP1M>=])*.SsD#(Oo8%bHNh#_]<+3OJ%h$EN:0(1%TP'>N`qMQiu^,n.WiKDndK)>bn?%Z:#G*vJ`INKF39%>SE5&rBLG)B]e[#F([8%JcW$5RH$G*UAeD*p@NZ#heiY7)a0W$Rc([,IBmD-e>KK1:Ie8%KYAT)AukM(/#7`&/MY&%Hq*]#rp,a3Mj(*M^25a$_44GM9%,'.[o)?#/SeO*MT>j'pIZ.'@$^f1t4G&dg*P=?gs..*;#K+*lS[]4[o[_#&Cs?#U6]<-Z_V=-Wf_w-BA$vLn9da$IT^u$OoFv,Oi1?#II;v#]N8[#/RrN9l#^<-aqi=-$&I=.6u$s$H8o>5@xqv#j0As$I$J[#j9`)+5r_V$liX;-HW8ppD=wXN@HN>P9Xsr$A=+Vda/k._Ej?D*J?@M93Zr.CFfUu7gnS]$vbLs-i.<9/8-U:%p&PA#02ur-[t'E#Ird5/stC.31IqhLXe?m8Ta3j1ZsY]'4V*Htm+xD*?.YZ%aJ-_#wv:50MFD?#>A&bGJ.dY#^o6.H_am`*b:#G*(-&?Pt3R=9UARH)kp`pTLnfRPST*r7K'ZcaL+w5/4Tt^,cNA3M`*LA=amtA5h6SlLd+3S(HGlY#J>IPCaV>W->XJ^ZlXGlp?<-h1'&>uu+/sW#N)+&#iid3:K(Zg)%HvA4kYMu$`x;9/q):H*<5.i1<.FU..=_Y,=EOV.GO=j1bH?.3md8x,VxG=7K`KVQ%+O8:NH<j9:w.t%bq%N0j:urT%O^T%`;G>#4(%<$3>bE*Qb7@#G(Z>#6cP>#@Rr?#$j7O<:NOI)DJas%PdCk'`nHT.?1PI)tv>4DAneJ&P`U>#/JHd+'/Kb*(ETW$H_*9%Dt8Q&%####Bg($6lR.>>7kb5T']1)3Q't'3)TR12p'Qv,G#[)*mX_a4Hqn9K-.+D#qY2P-[HEG)g>b29cfM<%NvIq-b-9q%A)c;-C&&m-1L1<&9'u89)Q2W%N3hW/HJ>d$#PoD3OWt&#FPj)#,$###0k'u$q'^:/+Z6lB05dG*-1Es-@63r7mGA4;84ofRUFF1%Hx8$(dO+o3sKRI-r03g*b*>N'hVnH)Ee9V-^Pdgb5p:H2>;f8/o6u5:cx>*(Ib0.t9hbD#aIcI)<xNb3I3f;-gCR.1n4xD*U<RF4k:8C#tq7>'gJKYhQ:43':a,vA5v$s$PZLqSut.#']XNp%p#&eGsWq2Bc3EQ/h=+w$Bnxi'V4+gLn3dA#El7-#Q3=&#<Ja)#'b.-##<V:@W8Q$(Jm=H$9IXD#wKTpAdD24'a>^;-gi'?G`.gj,O<mh5^jdJ$k*Ek,j.0#vc]2aGhOg9rcg8b*Q'(6/TekD#P^(%Q5A4SQ5rd*Oh#f)B=U,?_o[PUr:ikA#l&3vR-?^uGxe9N(0xFS7%QgW-gW5*np0mo7j'xP'Es3^%;t@.*CFu$%hj)9/x<j?#_Y_o%0W7C'g;M0(;';hLCqOu+EAg;-JW5L1W8k/$J-t9%5@*,5I;w'&`4`BS;KM-)'7kV7ELY8/<M,W-,J<X(<'0PScG[p%O;Cf>'k0hM-)l'IZMXm'3O?M9am+rMNfsNX5Mp&]6ZAc$Uc(d3WxZg)I5^+4(UH1%97(dMcB#fa>RFa+a#AiLvUoYM,)2hLs1N*M]AKu.&^r%,2O)%,.>T7J0tu?^ih3>'Q=4J2j<,LU+2r_&DkDZS8.r)4oUn92oK-bWqVuAJl*_)Ma?G0.4K'%Mu]j$#S6_c)6?i,)?b%?5aKA8%$c<9/%ZP^,[bQP/iq_F*<Nb)+-=q2(M=)rAg`P>#9;#j'OfED(p8cP9E$6/(/qvN(*OLk+(OJs$#Xu6*b%?lY=LG&#>&lY%9DH%b<G?`a^hHP/PW[i9+$?PAWw`uG<Wd`*)MT<-e$>44<$+r.sJ))3*0=L##BqB#1N?.%qYA/&C)ZA#n2J;o3J;/s;4dW-8qJ4rH@NfUvbj<%EQl/(pYC(&W7^;)u%O-)8MsILNgSa+9a5_FV<Vh$=HY,%Bu:U4t'Tu.qZ;-*Bm:Q&wL/W7h[l<M=.Pu+bkP7_7Ib8R2%PS73jIs.#$4K3KT1E#g4h'#XI5+#CaX.#p:w0#c->>#Y[iik7tH]%DE+<-:pYsH6'$Z$I7'L(B(XD#`w[s-V%I^PX;0(O1^GA#BjfI*(/rv-g]]P`[t]:/+O@IGv2`X/vOj0(C_39%u^f;-evA'&>-niLnH5rd$7I],0$,T%$;?H3OVF+5<C];2t$[gu6W4gLQIO.+rDea*ea^W-C5G@9:0G(&0hF(&cejO='=2'5;gB)O$rJfL`<R##;j6o#fXL7#W-4&#Ii8*#v,>>#ak6^]w'LF*.kR0#9JeA43-Tv-mvdOKgX3j1&(9q)pDPA#qYOj11&))3xr<Z%rn'02t^3O66NXm/8gKe$Vnhl.H=_YS$60PfbF]w'4rpf)D(i5/[@.1('B>5M*<jJ#=7SN'Ysu3'jbqJ#1*#<8H?Z51aESjkT?9-%K:I+5c<Yx>-LFT%[@JU/Qmav6N)TT&$(s5&:Kx-$(*g#GQB9q%C]+d(R5r%4`o$0:NBGd3?29f3E5Ov$?kIq$:sPF%'8Zx6B7A.%M86g:^9L'YG']t-G(7s$p%]L(avSe$LFt#-/8k.)LJUiWk,1h$58oO'eM.-)@L82'OPs&+@RaP&OY8B+Cq]M'B,FxY^xU/).^v&')*6qV5c)t-FaqL;AP)0ZUiY1MA%D8.<f-<-ND&$2[3rZ#<&D^#H-,3'Uas?SL>q&$[uo'+FAl_/%mp;-_OW/'jPbafS7[w07u9j(.Zk584)6@d0No._[[-5/IgSc;/H&##hP`;?JBav6R+h.*AP>s-nhpb*b0tp.FV7C#DMD(=^vcG*m:B^#RqvMVY9j?#.`6<-lHem%FRM8.bF+O4tD^@#CDRh(E$[D*Kgcn&WUDv#[okxYZ9F1DQ+;mQ]2Rd)@xkHV(f>C+kSu;.l:x1(=oHN(cB+=$:WR/&p]q6&j,(q%:]G>#_)?7&`K][#t^Zk(btw[#M6ZE*J6:,)CxhV$=H;G#8p*;0wTw31q0D8.@V`0>*)U:[liN**N9tT%<`mX-rPn0#IO3T.VN0q%CA(X'nv?D*?HcLs^OF+3Bhp:/:5Rv$7QCD3Yn^h1@Gp@%4fcYu(+D?#IZXu7o7Z;%$Okm/Q/%>%wVvA45>w#'9e]f1aGUFINNG#>)8FA[8vO%&<6Tv-khp`NaPXD#H.ZkOd$92'G9gp.()ta*t<5Y(]eAQ&uh4gLw=B>,/sg2(/(UkXwZIf=.wIX-KwwQ/d>dn&*UK;IWEd:`w$cWR.0hp*NrMVRL'wB=PZquZe)S2io&^%#`5ct7iKC^#12=a*=efp7Hfa)>ssW?#M*TQ&e_ns$H3:,).hsq.i;+.)WHHiR#p5Y%iXFgLYdOp%Up>7&WGY$0Gw:lK1mJdt_*w##xUs)#k[P+#`'C,&FL?K)55%&4_R(f)M0$?>n/G)4B,l%9#Qic)20/$n;Y[&4Iv'J'wwU<-@o1I$5)J-)mkjp%%ht1>vtblAuVdnA9ScqAeSFHVQ<B(MwRwC)9xvo%ZTXp%d[(%,3(>gL(ru8.O3jxF->>^%I'l%l$:>R*;3IL2'/###%b_S7EvTP&`U18.757T%'rB:%Cx;9/v1=^4m&L:%A7^V6Oxg.*OV>c4UJ^.*_=@`,V5MG)B4r?#)Sgq:X`*X$M4xD%s$&T%8r:ZuDXiD+vClA#iU39%oQ2#PdQRh3IiVs$Utl_Pm8wqnkYL;$2fQ4&QHXn/6QvS^)N)n#/5BAtA@`Z#'=F&#dPbDNNo&%#p&U'#mqbf(8X=@TSO$ZY%^L(.;tV)+s&+M-O-:w-Ld+hWUojdAXt2$##Km<7Pg5N'W_d5/D:.##&7Js-q>W&+[WOT%%Ov5;.1$^Gp[%@#E2buPD4H@LQ,-v&[d^Q&p#Ap&mE:iU(u%b4EHPn&`>kl8HGPe-g%hY&Uk1H2s+eT.Su###%vF:v?FY>#B[u##Qqn%#k$(,)(&;9/sJ))3R2B.*+mLT/u0Cx$a1tj$&ZZ.Ogqg)l]0f(%c,Ur(8,9>&&'k72o(kg(OEp6D+-<2'i2?a3OFIw#&nAW$X*<?#>O#12?Iwo%AGhj0A4r0(A%S,V13C;(IBSn0XPF]$iTk,2iFSX%-m3t.k4rv#b'4p%K&Nd@]B=m'b-[bU<gSSU6&6X$X5um8nQG7_d2Rm'DT:D3_:2<-g%vV$*:`sJ]b9mA=?G)4p$&Y-?]u3F]>]d3+B;,)uF(s-O<P0LRJ]nN^d&$0&Z29/&9lt$5#qf$P1'R-PS*>(C>:fDx*LB#m-78#eCGc*euDH;n;5H3l$U/)_PW]$qY=O2u>kxFC_39%KMYe$1P_w,C?XA#9]`Q&[P]X%&^,T%v-#6<a=/8@$@#v5:sst&_BE)j_Ebp.%5YY##^+3).YV'#N7q8.KjE.3an@8%KKBp.j*'u$+m27:VmVa4k=8C#gSv9%U&/ICG0nm&IwEX$p4[U2l=1M):L<9%l*D?#aX.V8%f%b/U*VH%9+e>QHOx?6*(+>-I$O9%*b24B)C@bN#K?>#H*V$#$:7I-PvDG#%u'f)D+Rs-a,)(=5/^G3nk5a30r/GV8D.cVdD24'O?L-)gNi&5RxY<-pFMX-F>D_&(H:C&U([0);WSa+9f3A-GEH9MI]sfLE/34',>###h^YfLIU;;$>(1H2K_R%#n2h'#HVs)#'%(,)PvHj'/h_F*:27C#7qj?#l+]]4dBXA#u3Cx$>R(f)Tk0,&W2))3wT;m$M]WF3>TYp.U-X:._aEQEiGQj'c;qi'$j4'%i_rZ#@]*7M%E/cVNgSa+D$Xp%+p`/1`$v3;ZDF]1UXQ>#xbq_%BE'_,PxZwJomgjCF%SC#CODZuGNf-6aBbr.DRJN'&/K;-fY&v.$jSr)QQW>n_0*?#]ZI%#+^*87p*5gL^>LZHZh>w-jUKF*jx+G4rg*bRr1AH<VC0Z$FL9p@D1`BS0L][#qoo]$+)Fs@2cMcBL+B->N;R'4Z2>C+Xh%[#=F$p[_ImP/v4[m^ARtVf^nH>#V#x%#]$(,)1h5N'jZiYPX.it6PTH-&'Eg_S@B+a*'#Z,(8:RH)Jg4',+7>q@>n&6&WB=Y'$-mK5iNj?#FUj^SW+4p@PI'gLL_CJ)3Rg#(LB'Q&(c^58n<g'/S0CwKK,5uuhg(,MW4DhLFwl&#;kP]4CekO:Q9d;%c/v[$mq@8%='J,3CDZK)jX@8%:q'E#`0`v$8;f`*l2e&4]/np%U3dr%:9Ts$9fCZ#fEg+2Z)_6EOB$$c,S1[ESa:,)]3IF.^dK=1KNev$B6^DCS[7v?Ycq@-c.1lLc<`-Mb&mK1O>]iL<n][#a68x&RBuMCAc*mLu9Ss$80eu%:2%AbaE]f1Q3Z*l-2vT%8,PZ6gH7lLmXu]#_HGd2m#:u$'pus.8EtxFC_39%JMYe$@?Q3'^9jv#8D=7'#9tv#1MR',F>D9/<?Kf'9`rq%mbF3'G2VZ#&c5Q8LQGQ&Ce3p%'kG?,3^_Q&6,Z5&a0v^#8GQ%bQxMcV1Q+g29X-T/j=Gd=Z-<iMmVE.3[Z*G4an@8%;7Is$R2u`O#VAs7+8nS%[..<$xG`-%u<5B$c`9DjaI:k1B2M11tQ^0(/]'xTs1qh=S&iG)*.Gd3Mu3=$FwJA=r=;v#a9n,*j9###%&>uu1aaL#CxK'#%sgo.atr?#P94eHIe75/Zb(9Jm0>)4oBKj0[/*E*[5ZA#%+Zg)I;wM0VC1u&]ggQ&M?[gLQA1*<d4P_J9n2'5Q>DlM$7tXcbj*.)#3C@'IHuq2*ti@%=r(?#lii#5UXB]$7+oU.CD@C+Hu@3'>k]f1NdWf:G4De$sOoxA@`)T/7Mm8.g<7f3##lRJpu9HkevkCPciVQ0VJ;)8%:Bq%gTEkLnwVu7D8:WLhZlr/Jg4',94bh<u*hb*i@4N0?lu>#mH+@8Chx>M05+A)1x;F%:_XAG,6:h*p_=n/n)^:/g@@/$uFkV&_r8mAFY$3q99=8%MDW]+QmA3khZbK)PEZd3dc%H);5Tw$J29f3DMn;%`QDOBLQD-*Zj:9/Z%FF3Ju>t&x)%w8OxcF+wOk.)b,XX$V7U6(&Y'@%A(e;-6^5W%)9Fb.&mtXZG-9U%=ux[>+G04L7c=>,nN*2005r%4]$%##UmFlVdcTg-[2he$(Ov)4')'J3=s(Y$l9Mj(;X^:/ZO@a4'Xwq7@T7U/M)D^#o-24'YTF+5_I:&4wi*.)GD0;*8wJuAjM6',TI?ofQIFF%dN,p<r-qK(0(gn/?`(0MT;ojLmYGwPa7@#M_Pdo/T[i8q3F_'#tJW@tP`%/L:,NV6Y#B,3*56R'XQJw#v;Tv-Xngx$S9V9/kon:/`Ld5/6B1C&&'p]#sOsD#Z/QA#cl4Z,l1pb4*xV]F?C[8%+#6w-gh=?..-:Y$dk93'X=gMB6%#[5KT(g(6>h(,N)34'M-Xk)P.d>#>$^Q&js*39kxmo%U0]8%NA3I)wq1)+<WTJNO.u)svH<Q/KD8^+pbBN(Fr_C,`I,D#jhtM(`GvR&,_IE+M^Bt-t8bmBi*dG*X*bT.s:Rv$ugpv$)2K+*.7UC4AvM%.i>k4<eG?0)d2/'+7bqC.RT<N1HFL2'Ps2/)vYFRUpJ26T$$^N0M`uS.deRv#?+J3'd;###fN,/LNrIG)x)'/125V`3B@0;6h>3Ka>JqW$te?x6@f%&4;#fh([hi?#ZVd8/3eit6VHL,3#*$E3R`%>.8$<8.FRoU/YS1I$%',F%=$G&:Q=Ha3dZbG2Xwiu%Qfm[b']3D#C12?#iZrZu,@.D&prB7)wu[T(Og)6S_JFU(YXn*EY/?v$M1`e$NNcA#2Vqn#V/%-)w1058MNPj'k6V)vOl$SVJVj3GdmG<-%(IM0%,Y:vHh8E#irZiLb??>#eVT16T:Ls-[J7&40Pr_,jh^F*'[U&$F.<9/CP,G4.15ZG8o:Z##=Gj'NMl[nuCum'iQ/R/Cual0CjO',xr2^ud<)D+Wa%[%XoPu-Wu,##EEe#6t4L.=1?-v.N6>j'mZ%'5m,CV.o++J,+#H_FV54W6+mg+*os$crU,9v#COqr-ggN^,:7%s$B.i?#QNNjL1uQgD#2YD4hBf;-un7T%[gxFiY3Ev6IcLv#.Qc++8T@H3oi.h(YfiT/%Qrh1L%+0(R3b1'QG+m'eAtD+'N::%9;H%-n.0c3-n8s$/m=F+V@.d+fN=g$I2>>#M]:E3U?O&#(K6(#HVs)#ibY+#omE:.=p0W->vq?[+fj/%mX)<-iLh5%vK'H;HSP8/Jn@C[ULc97O;64'xSO-r(f>C+x_5'5CM5>#Nnbr/8Z%123D3JUm&DAPpWvf;@Z*#H0(LB#<UG<'91+rLZF?C+rRa&l4*S5'agmxuYLN>.Q5RJ(iP^G38Mo:&xfc;-4W%:.%/5##)<$N0C7>##eH?D*Q4qb*?N_<-u^<b$jlOjL)N&],X,U:%[5MG)82dA#TglHZ+%W9`TrZT8a2?r%25jl0RJ<e)lb7Z7Gwlx4'AuKP/q.'5jbml/Tj:11@48j0QSDP0o#`K(RnU$v7m6o#WWL7#gd0'#C9OA#7)S^.HXX/2c5h-%+*>9/&,JA4X)e]40V_w,UkH>#P52k'i6`G)o[O,Mo=>N'i,K+E;Dq9RI,/t%Bf,cG;?J.*L)d>#n7OQ'BT]**_YRB$BfG;Dpf%d)Pr$IMpH$=$e;?xbFX02+m`V6/v>$(#k`Hh*dvk9.TekD##w;gL*mL-%UITY]''Bf$%>i;-[.A;%2tFA#xGY`<.+CJ)d4u;-l5a+l10M-Mh#6/(5>*]>NE8X[9UdnA/MIC#T0T$lkmt9%-ba3&b1tJiSQu/(sQae$`0bOM6>(i<-HlT.IXI%#Fn2#&`WJO9h-ge$[j*#&97WAF4wFT8-RZd3M4k7hqwQd$x%x6**[SFOK#=a*`tI<-G'f33v2h'#4dZ(#N`aI)&)A_4,#$f*6Gr20Q[tD#x'cJ(&A7Ks2OXD#rTsR8Bo`#5sEk=.KZv,&LoEF#-w?aNdD24'R/gV$x>865w`34'.(k*EhVnH)?<9Z70_Gr%r@kT#;;mp%75m119#c+`o[sIL93dr/H2Cw-i5:pLBPoH)$D]5L&(LfLt-gfL*G)^#cE+.#Atu+#bkP]43#,G4d/Z%-e:PK3q`Cu$$d(T/B4vr-'($Z$nK/<-equ-M8'xU.gc``3a*#O-YP>s-gBX_PNXsX.vCZd$q[OL%6o<0(1M.4Cwt_s-R]_s$.A9G*+(('+1:))+]T_xXC_39%ee39/>6K;-$q@n$=8jk'eAVk'lEFG%##v]uJZ%12%,nF%Pe8R&D)+**06*-*B:D;$B4tc)dCgF*]N49%t:1<-6F:C&u,vN'5DT;-swvi2AR[Y#YfY=lGS2GVm)j(EQMEB.5)Oi/cx;9/?;gF4^ts20gc``39`p>,VMNs)[@[s$?=]/;3RA%qB<h7&u#Mf<#^eM.$X9baBZt2(jEgbaM`S?-$(A;m93dr/:?Bp.dD24'+wmx'Tr'p$D,8-#%2Puu.BLn#t-78#[9F&#M>.l'R)LB#k%AA4[^<c4lT&],VpB:%d9L]$?]d8/`-4q%K%v>u@Y:a3wO::%G)sB4q1-Yu?SPJ(HG[3D:;.'7/S9,7olsb3(-s</njSn/^^'LD*VQ<-pL2='VwDO<FN4u-Tl4Z,[PTG.h_<9/*r#j1$qk_$677<$T8[<%0wA&=69&1=7^I*7gOeW$J-fw#hPh'#$,Guu0dqR#e:I8#[ulW-Ah'[Ko*TM'BO=j1-Wgf1%OG,MEYd8/9/^n$<-+mLZ_YA#2P,G4/[/I$B'PA#kYKq.]0#3'H?#7&A:VZ#&]:%,cmT#$[0J[#v2Op@&:cm'JSl>-i@j2'Y=Y?,2f370.%clAS]ZT82V0T&G[<9%5[[h(($:3'AkhA5jN7-3i[#Y%.X,B$A$'U%_r98.joH(#'&>uujD3L#F[u##R'+&#h$(,)eDK-Qpqi?#+=tD#(+Ap.+o@8%ZbwZTP*.0)lH8j9=)Wm/XB4J*T+DW$wIcw9#ggx,2je6'933`+maCa#fAMh+Ss>;%:YG>u?n.T%gr$C6J8j%$WGg%6*Z(a63kHE$L*C8hxQ;[%]TVs@wstOS,E3/MKVY8.`D#6#nvLH20WH(#@2<)#e0;,#>*'u$.gw:&SY^5B87>d3^wxR9#4w#6,R(f)E[nLMkxId)/##jL;+b'4TmwiL1Q/(%^,,W-nH;wg/@.lL6]6##dDI-)[XD<'+]de$FC]pA8IvH-uQj-$_nb>-DV5W-)d_v1&kY>-b,Ok4;T&pAa$rn3BPRKWgBn>#U#x%#mrgo..39Z-a8t1)I>WD#/sYD/4Bic)IYpkLgEL:@3W4K1GS+?,^?#k*>bc'$,:>#%uri112=uY%R%*Ab(f>C+%3c405fUS.^>i0(w&Nk+oBbt$BQ+P9le'^#^$Q;&h4$##t:.a,0$$E3LERb*$RYU.VU6K%D?jp$X0[FNLWqB#eNS+##p=:vA2QtLRX%(#p1DMMN@rB#*%'^=*XsT'Pej=.Vq'E#]urR8w(Z,*Z>tR8r_21):JeC#m[cN'.H[p%iuP=lQiB(G&>0q%sTC6&jGW#,5N#ZGq>hd2Gc&Z$78M+Llu;s%Yk=NX<<.g)Ubsq%w<RH)%TZR&t,)-)Du'@07u5H-%5YY#/UVGaik4kX(:iWJ%:L+*^q[s$aqi;-Ill8.3v+G4D#1O+I[lS/]J0u(^,ZA#Efu>#.M_+*F*^m&oi'6(q+S5'^aZp0<G<X(W^,S/M^j)+TPC$-lue-):YL;$v*JT%Y%Is$8Hs8.s9>n04nD;&x.SZ5F-?n0F>w;%JTPN'l'wp.<]l>#%4q/)=pBn'^3J%#odV8v<k)'M]A*$#r&U'#A>N)#_C,+#t@)p$0Bic)0Zc8/0/q.*Mq[s$(8-W-*9*hYS?,I*.._C4B_x:/Hc*w$b8Rv-xmA3kN=tD#$8^F*pD2)3;nHv$cLLl%8J%em6tfR/*a>_/H%d,*:Tf1&hF>C+Kqgr,x/KA,?naa.82-w-P]<$5'M'J%ZLaP&t4[$$-Gc>#g)e)*MO5j(,#9;-]1i5/pY%12_M3*MpEjZ#l4o)*(6eiLuhDv#.T;a-#bP'A0,W1;7Xd:&*RF;$2Ar_&R@B1pXM*i(EbS8SX'tl&90i)N]Iw8%R[hXMm5KnL`P):8'kG11U9S@#QI6n&U)$r%qx8;-*.K0%Of6D<N8mv$5Zcg$G<Tv-(t6l182Cv-L35N'D,7W%Cb#V/;JjD#HjE.3nfjI)D8v[-#2J&4/m-r8W=N`#Feh,)F6nc*Zr:Z#A_<9%t[2T%a@4,Mf)=Q/FNa-*T^X;.k&lX$H-VB#JR39%4o$s$F2DW-ZT[w#oVhU%Kw?G*G?^2'1Y1v#=C[W$e[C%,5mRd)OBaI-#^7l'KHnv$GEP/(#@P>?q<)-a=J?`aBgZ`*^SYKl05Dm/:oU@,f9*Q/b5i1.M2FjLMZ.:.=@[s$Vt+9.G1clArbm(5p#i2'MFe^&.qZaNw1@N'mIamJ(Pws$LpM`NM4Tj0Y])T%-:.<$]noi'*IK0(;U*9%x5=i&].Us-4(.<$OtM20%)###&e_S7v3Us.14^`*:1>T.a%NT/)`uS.GWRl1$`uS.>;gF4]l:p.?Hwh204pTV#&'f)RQFv-2Jo+M`(Fb3*^B.*Nw7>-L*(V%6LOA#jPe)*_*JQ008<<%xcUP0(sYo/`g+]#l_.s$=Cqk+-3'_,]em5/S(W9/&jQv$hi_^#0eWm/%8GE+HGZP0WM^=%ug7*+6sRh(ug49%*kdg)=`D^M,j3r0:mCSI>IUf)r34T%WfLj(#VJfLu3pfLT_?>#0-[0#.dZ(#p<M,#CRHV-;fS&$Rq@.*pD2<%.HL.(H.,Q'eL0+*#Uu/%mPi^,c6I>#HM/o8hQkxu<RSZ$2Bdn&nRl_+L9N*.&f.[uEfBPq3sc9%NQ:g(=[9h(dS<E*C7[s$.0Zmo:]II2;kq7'v$kB-)l.T%ObUb*:gd;%F_6_+0H9?-)e;.3WAX9[/r6s$]D-Z$l_4gLiIci(Wn7<$/AP>#SoIfLNU6##s758.HWs+;lCmE(hjhRJvP=@R(kV@,l`ma&)T8f3RV?p%0BGA#KO)Z&Te]CMlsOo7u2os%ElZp%NQ,W-Y3pZfNC-##l]v/(575+%*t$K<dbLI5;)ge*[V.9.Ih=U%/jRx0;-:'#'&P:vgPEL#fxK'#YY$0#FqG3#h)^s$B00a<1F3j1@T%f&)dY`<+nBn';L7[#>.e8%dI+gL_B]s$UZ'@01B6N'%e75/7fHMMdr=c4s0_fLg6[q$s0=H*0[7x,2*,d2)R/[#OHOA#Dl+s6dgp:/W[3U2$-`;.AZnU0',wv$eC5Z,-9..ML`$#QY%C8.D-#j'.N7%%vahv%hg]8%,QF?#;=R<$C24W6<bPvGVfO;-mS:B#*0T2'<C.[#h0%x,IX3p%>vZD*ggo[#57.[#;hAm&[a06&a-Js$Mn<T%eMr0((k3e)HFR8%Dhw8%_?t2'9YlY#>:VZ#G_<9%3S(v#W00u$F)w)*`]Wp%c`9>Z.?[?$1uhv#C=%[#PEDB#Ix+4(tBw.Qwpg(5gX'R'qAd<2G%Dv#t<Y/(K#eD*k^s2M_dxX%Kqn8%tH:g(7%'p&l;:l0ChN9%0Sl>#Nsg>$e4te)G:'p&Yu=e#<[<9%J[.w#V%]fL6pj;$TtpC4K9kX$Y_aT%))#]%SF@s$1Mc>#+jK[0*;JfLIOQ##Yg=W-3#H:p0FF)#hHYs%_:jQ/wHeF4MPsD#kVg;-9Sdp%4PWD#lU/V%>T1p/Fq'H2p,f;6)dS^+;_;W-7Ta?,jv^1KV5do/+bC=/jf[_?:^eQ//4br/V.am/cIAj0eMv4*-dds(/XHaNQ,u;-PY&;%H>uu#KoZp..bY+#vTO`mno<?%wlWI)*BLcd-fZx6;,hf1T&5d3j`G.DhtL*4+gB.*D%o:/`iY1M0UGm'&%1x5G#[)*le4D#)(u/1HS?%bC_39%LHt9%A1X+3K6NH*rxP=lu._n+S@Gd3[Q53'lK49%S9Bq%DlL5/h.d8%H^dgL1EfW&=L[S%RMshLYw`v#lSPW-GXE_&>S2P0HJ7j1vPK_,*,2%Gp6ar.X'*u3,aiK(CH>R&;%fE+Ax>Q8ug$sAlO&]$OF$c$5/-T%*/5##:d-o#:WL7#Yd0'#/;SC',c7%-5@AC#nBFA#Dj0I$QxWD#rYDD3D+p_4.@sp%2;v7&j/^,2U[c>>XZ+>'gDvV%iBo+iiL*I-OJZs$(s$W$u)qa<TP'H4/A>##7l5g&Y>nx4Vpw.:w0+;?2:'XLQIcI)@f)T/2Bq-%13w)4HjE.3IG1I$'o2M2xraI)#os[$URoU/j1e8/u3YD#[I,gL&+ip$ZHFs->d7Z?d^'^#sf^58s9_B#_Nds.HlpNg3J,W-Ki`C&=?5A#,x;Q/iGg+(#1JB#F$;B#1Paj'BNV^qfR@%bp[>mUdAHN'Jns$'Wc4E4FXwmL^6Tu.MD4m'/LYj'$7+;.2M,NB$6-)OiYr=:#ET)EdjBn'$sQ]4TW%29a0Vd*Vd,6/atr?#I2bd*,IZ,M;Hjd*OZ6k04g/+*s<RF4JC@X-n#,W-s8c'&43`u5+__V&P?^Q&Gp0I$-d-MN1$VdMh$&s$td@E+a*)p*GsnV&5PafLFYN#.,-neM#f(eMfT>*&%Hp7/%ht9%^][L(Moteuw;<a'P2P:v9wV>#I>QM'*@.K2?=#7ArqP,*[1=n-O;$+%p)Hp.mxG=70XB>(oQ,n&#UnW$del8.9G>uu<__$'1d%('m[cwLTnCj&5+)X-<MN[')gVw$]rte#oZs*%gH:g(aW@)E)o_P/Tg'M:g[pTT`.7L,ET*)#$),##1-1n#fXL7#Ksgo.ig'u$-E6C#4LRI-;)`x0GQR12Fp?d)nM.)*VrHh,Y]+:/OJ,G4)2/E34tFA#W2a[.94^gLEG9f32Pr_,YTx[#wZ=42R'`^>.Y1Z#.(pxX.0wo%A^j`#RwI>6qQwV-x+rZ#EeaT%`%#?,(XXp%k)k-$Y/YB,x[s9)i.iZ#Z(ma5QWIb4$?Ld2+?QD#VJ9X:Sfe7MTr'7'fJ8A?6#w/(Og`n'r7>f#LXn<$7]1Z#cSG/*8-LJ%=t:vY-+L=6m$jV$$Oh0,r?w%F<sk;-a&Wm.*2<)#BlWU%P9kB6A/i1.-CTfLrI$X$='A.*KOg;.21C9rL9cO:S(>)48km;%:UZQsmJ))3#1<:.Lk*.)+V0T7jGPb%h21q%cmXp%#[)%,RV=V-dFBJ)`9T1;eILFGJ]wd%bfLT%OAj#la4+wp/L$D&LYFJ):)*b0_Pi0EpY:P<blD2:JIF&#72nj0aQ?(#EVs)#q2f.*Q?Jm'eSkwn%SWj$c]DD3T#Yj&,j1<-PN9o/Dmng)'@n=7_MG959#mrHZs.Jh&R^Lp?gwW&R9Bq%AhT15,7.I-Sg%T%wVoo'#+A%ba_0C*'*S*+,A>;-?B1g(`<%L&)(lq&MRTQAD:;?#0O#]>5pPL2o0&?7&k.?&W:Lt6)(Z(+T_5(H+].(#)wmc*xih,;1+6u8tqDi-2?$%ls2uA#N;^_k0u.u.IoN/2jt;m/-N8^+5u([,?/`_kSd.a+%hNRm<jSa+Fj'_,xD[#%hj6o#A^U7#AXI%#6(cOKtK`t.lAqB#`I>87@S))3w/uq(&#.i$/Aj0E)LLA4A#<**+4pg(IkdDE`uw-)BeK-)h[l<M7`U[M[_Xt(wV*I)K/?Q&'n:+rfFe--O,Guu9dqR#sYL7#XPco.B.i?#R$&$&#`d5/8tJ#'*VnTglPl]#Ff8^$.hGj'Ytu3%L^B#$sfC(&%aYp%AskgL]*8s$*sg7*Suq;$M`7f2VVwW$hfCv#v$^p%vatT<fi?['P$=)<67]:.3oUv#==Y&#wps72jdW$#l&U'#N%T*#1$S-#`tJ9;T>gG3f*B7&ruV>GO%dG*:uh^#1>l(5dF`2MDp`v%%aYp%[2JiL1Xnm/j=9a<-P3j1McAGMCXv<-1-r[-`0Nq;*7Wq;p%@k=VvruL<k0W.Y[3VR`;^;-I39k02IYp%-Z=J*MW?J?7slG*J3G9Rc1L)RVrJfL9bhp7Ze-$?Qe`uG4bZuPH9Y<%0f)<-=&M-%23<#YeO&%>r0^G3]p*b*akeW-49`B'DT1p/E0p[uFNi&5&=@^?qn5]%S.72Lp?G_/]F`2Mniw#8>BS#IR:Yp7pbkA#4A;A.NgSa+X+4W[:[r%,KUVv@MZ3r7wZ((&uv>)O$cdERt4M?-8vYOMdq7Y-htOk4BwwX-BDD(&M6eL,q3n0#Xn)vu4N_n#hXL7#Qj9'#L+^*#)Oi,#pkP]4^bm5/2a=Z,ih^F*mq:p$1#>c4B7.1Mct1>6>-Tv-.@le)`ni?#(&MT/v0UC4_TO^,C*TM'8.sY$jN$>%5pf.*oIs:/wY4Z,jT@lLSG3^4b@b)<(Oo8%7vf.*-L0j(U9Qr@KQ66'k1L8.BIn;-^je-DPU/E+5*8],>AY>#eMHh#U&;0(T'lf(afY>#:5Xt$JG6^=KX]I4lL^>,75xqM*mD,)#`A`=%N^0M*.Z7$==0Y%Oqk019ISH)@JiL1F9A9.WgOp89vcR/qms;$Dl$W$lqH>#%9VO'L8IL(?X39%_/Q;%lxgm]l'(T&L;MT]sr<&+O0kC4Z/hu$B+a01R)mO0Pd9W$Qhi?#wT1hL._n##'/###fK#/Li]cf1BLgr6jK%##I$Jw#J.qkL2K6N'>%NT/f3rI3]Y#W-FukaGCHxY-u;Fwn9@RhG#KLm&<:UT7pDqq%k1Cw%nhe),M@wi0gFYF'NKw?,e&9',2$-F&?E3D#[7tI)leQ5/)mhu$Ca.51O(R8/Vi+/M$xS5'wwU<-Hh.Y-:#EO47kAf$T7_,MG$8(#5RE1#>mp:#1dU)-rV)]$EV7C#k8Ea*nSI0:+e<#-j-pJ1q:@<.w+m]#[*'u$GBSCO49Hv$SZLX%T[s)FWTY8/<F9_-OM$_dci=c4PW+<-ge*Y$ms-)*UA,c.61rnBJ79Q?'`/T%BbsQ/,aGT8*#cR8/cgL(C_39%IKnS[mj4>';#Jo:Xx?%b-[wF#auq;$;@@W$;aOU&[d^Q&E*'q%ZTXp%mbkcM^wi;$-8foTlc>$0Jg4',-?7<$G7wa/iTn%leM_K):04^,Ng4^,8Sue<KLD<'b67HD91IsAF1v7$4nhrZLAVH-xt+0.tn$lLMjMNQ=$&W$V>Bp7$ALX:,9U/129wK#Pqm(#Lc/*#.QLA&gI4.;t.G)4]e?a$`J))3R`:E%`LoU/$E?d;geiMi-+x_#[/aa#o:@m/okjp%Z;24'6xIn$MY=7'??w$V5A;',N5sA#`Mp;-Pi%J0CXeW$Yobm1m]YF%,qPX7&,i?',XHaND@(gaNbB%bAO]d;SFh'#&2>>#P05##Gke%#$/ON.[D]C4uqr;-gSw]'#tRF4-E6C#*s*Q':7%s$[1t//X*fI*<;2-OHi6<.vu/+*CR[1MD:1lUE62W)bDVO'M]r%,p]-6M'b6j%g+E`#WWBY$i;Gb%p^:K(++2N9N+n)auT[=%cIlZ,O4#m'LBl/(oC^84(7?e66dj6f93n%ld@as-uN)%,nb%U%(?7<$(u*e%f+te);X=I%aX6T.c2iS0gbb,MvQ?uu&_/E#]Mb&#ApVF&39=Q8=VP8/F[h>51Qpv-iL0+*Zu.&45sI9&TC^mAf]V8&ua4C&C(Sj:DSw59Duti(j6taa#8poSx7poSu00%68:ZL<0aHY[`hc@57#;p/'$.ekN97I-d`Nb.t+3)#0Spn*h-MRJ?au]osKbO:G$.m0>LHt&dr2]-vu/+*x]]I&T#B+E?$(^u4s'H2C+%P)9XRQ/VJKJ'[14t?>(U4(gj=[0tF[p%/q:iOI_5rdNPbi(@p2a*v,2t-_M51Mb_p88mqcG*%5RQ/PJ))3?4;W-jjJ<-3lK`$'b)*4#$Cu$/kwX-s8:uA>;,f*N^g<6s.s^uomQb<]#/=)l8=@,AlfQNp(U@ksRB.&(M3_T2/`O--1<M2.+1/)`S[e2p'[>-_%vO0`Yu<Qdou##'R7p&nt2P1L?%29'b^o@W-AVH2O$>Pcq]%XcXQ9pX=3R)g$n/Ch,Cn)#B5r+.2?Z-K]&xc5Nw_#bBR-)QrbF'wHjm/J-t9%L4ie$FKx;QR#e%+A,/t-;'dgLK;*qMLd/sQg^BO0<'^6&;dQ-)r=SfLdaf@%7<9a<rN$3:SQ^6&(47I??-Bf$DBmY(9viY(f><ZOC7CP8ikh&lr%.GV6Wgx=(hMp$qf)T/N9Q)4$R:a#?W8f39ESP/-K?C#l[E$6/bL+*kon:/91FK;8>hR'[&PA#oi&f)04vr-+Os?#aIZR]`w0H2Z5OKS:/;J3fKOZ#Z5$v$72pF*^gm`*v/Pp%Nr-W$Fk*=$H&7h(J-t9%`MDo&;w%>-c62Y6APsGZA/#Y%@EL,)D[^l:UI*p.kp9Y$BC<T%DH7_8iU3p%G*Xp%FX7@#KiqTRg_vu#YfY=l+Ik^oW$4D<5Z&##LDQEn.<TAR)%=%$pPCp.w<7f3w1T9rlOtu5cTl$+-3Q>-);/CNBDNT/*)TF4'gc^,%tUhL_^k]>Ab:k1Q,iO',=sxCU&Vg(U$^m&dQsv#Oj5;%?e8m&iM>g*hOjr?NFV;$`)nH3v1fk*4IPHPQ5%F#bw'0+Ji:v#aEZH3oB8>#DO%@#f^>N'FkA2'947s$Vd2b7vxk.-bM&'+K7A_#MT;6&@fXI3Yq@(6xns.LhbH+E3_gJ)e$OK:<,v-3X4H>#bj*.)[-54'dH&CO:%PS7eXl%lo$m%lYU.[BT`($#;j6o#<qR33-Ur,#EH4.#^;L/#$;w0#-RT]90,m<.o/*E*R4r?#&Y@C#4va#fdl4c4PeP,M]HZd3E<(C&x_2W--o4orY9&-;*b`h)97#`4V)ZA#^nr?#PJt/MP`k/M^m=c4:e,`-&(>=(0f.O=ED,dl[h?lLqOqkL@@o8%99Zm/1^bQ%OZ1K(baxW$C0X=$qs0-2pF39%Rx:?#HwfW$O-X=$blDW%e5JjL'kd&5^Vc3'@;=#/3&3k'@v'T7,?%%%v^sv#(@X7/@;+.)kE4GOXh_T7pwP`klW),Rb]uKG<m1u$ZV.^,`4YG-+afF-fYV=-gx-*.kX(5OW^vB$N##@RU[6##JGmi'pmAJ1;b`FcKfPd$/lh8.iR=aGh>GA#2lHs-RroG=bwA[6wdv,*(0Z&4a-)*4lX9_Q??6^$U>M>$x-ikL%DLU[K>-9./heGVu?(Q911:E:n=X7g_KQnAUP(q(rUBJ)%Z(?#mv#V%meG$,%E&-<JTLTnr9L-MS;^;-a4JT%&wtu'lt/%,lfogSC;d7&#)/b9a5Z3'4t)%,?Khc)K-'q%<xCT.5x4U&N/gh=aHj$#ggvX/@a*P(h/D#-XCSa<uQbA#4$n<&2CNsA&BXa(:+PS7J3d'$5NF)YX7K&#iEA)4aoqg<$.[^9b?R&/wS'T7opHwBYxvP/I$Xt$(dl5&5SI.-0+_)N^_$##wc+:vd8wK#MH.%#r/(pLMuj?#rirO'%e75/Yj:9/5IL,39=V/:6+3v6h%an&.6U[',qb5/oi&f)7u529UR$9.'Y0f)PJ))3J7wJ71C&9.KB+k^Y3S@#9SVk'3=(?At_R#)QO:0)sW5R&xDlK16iqV$7:4o&,Tn1(X0lF5.J=<6U0)-e:bum'B,9$.[R;p*(rTe2SQu/(PNTq%]T^2'7%iV$%63t&&pH*&q63-vr@H]FVMW^H%DrB#UW=L#e.qkL@)/jOgPA+4oTIg)2c_[cV*CL3?$0iDR)_'[8+?W-/o_<J10ng)aQv8/x)Qv$0[FQ/%u`p%N<cC-r,Jd<%O(?%AF#-Mu;Uq%)PG8..h_v%76b2(caNh#Ev]kL-9Yp%65u;-G(-$&fw[p%ZOqvAYCU$.=L>HMLkFrLRXXp%;WjUI7=0TT'Gg;-c=*'/Tj)`[weV0G_ZY^-A*dH&iF,87kN%##2DXI)rxc8.?D,c4XxZj9.XN-vq(2I3mERF4>NQ_#[Cr?#>vq?[]_h=u#Kc-5(2f$&.RZU7(pd7&$N,f$L^9[u.Evq&x]d*3(tl]6(f>C+&1s8%9JnF69r/3'jVAnft7]1(mORsZ*36vZAa):MM[%ELkHt9%;/_e$5b0R3uNf%#P6<-$*c@(#praUFh_a/2io5CF'tC*4QBg;.Vq'E#LxB*[Bxa#-o(b.3HOBpRrhZP/k$->%:IMH**/<^4J`qR/'u)X$;bqw%YOhF$DLes$e^5T%Q-n`E=wJ6&:m=w&#_.Y0QO96AhE'>$o<_H)PXNX.t(NL1/n2L)5bHd3j`1^#;Wgu$#4da*c^W`%=wn`?Yso>GX8Q^=%74A#eElK(4)U='4f]>%')v<KIdh)3oL`C,I<Go/e?pQ014n0#_b+/(l(VG2kpLcMgToR'7Ah;.W4GH3wWdd3L/0J3xlH3btf^I*jpB:%/K3FN$4_F*'%(k$1I@1MfU>s-B7rkL*CXb3$N'i),2'J3/&wX.axJ+*Bi8,MvAUv-CR6.MRH8f3NfS8/^QxD48V:KM4MO?/aE^:%v%_kLAc&a#47/4=R0aqKT$UA$(`*70>4/?$8uLv#p3G>%b&io0D=mY#,>P>#pax8%kX[S%QJ%p&^@(w,/f_;$eRWe-4GQ]#2[NZ#R*+t$pmE?#8=RW$>^Vv%,:aV$`jfB?T55'6TU.W$6i*n0OiR8%2`:v#tM<q0<=@W$F@Nq8+^9@#C]+]-<.i?#QOmY#BXR@#RflYut9D;$qVpR*0T_s-)w1?%AQH3'*SW8&<@IW$tvRc*2oh;$P$;oALF-C+g3DP8PQbA#jO@p.7>)4#.bkUI*p'N(5X5bus,'Z-*@le)$DXI)CY@C#U<RF45Dh8.ox;9/xE(E#q$ie3Q(m<-L+2t-RWWjLx?o8%/vVm/a[2Q/`T)i2I2K+4A;Bf3jHIf3'sUv-SOcd33C3Q/Jn?g)_q@8%0=R20@]WF3G'B8%[C?n;tBjJNjcv>#_)X?';`nnCwkB>,QEoS%IaGr%J&Fv%n(ffLS>$$$fw3x#K;j]+Rggq%Up10(QerZ#6PC;$D1;v#C`c>#?_*T%r=w<(&MX,Me'3?#)5G>#.<xB/YYQt1'--;%Kuhv#1OmM9c([h's>+'(oObi(6cG>#Q4wS%<X^g2<'p[#?=cG-=6v%.%`]fLZS[r%ZK5j'g;QV%o1ta*cPVs%?_?A/<i$s$dqtgL6ng#GuwsRMO5pfLiv,j'V6@%$OpK#$n%=**fY.5'i+#?,9Q5na/4,i()GY##:d-o#&XL7#R9F&#9>N)#s<M,#W[U@,wb<<%s:gF4w0`.39N+J*Wg'u$]T'Q/;JjD#uT^:/H%xA,&'ihL#I8fN-&QA#05-J*m#YA#X?lD#Xe75/?[+A'#eWM0Gqg_*>lVL'Gcg<-$&wN'Og#R&@#Q7&Zw=0L.HI%%iYj?Q>S0'%8MjlA0/6a<_gs-$<`=mA3ij-$lsR`Endce<^+1l2;3OD<I=qF$k9wi&p.E`#prdJ(F5j2(CT-)*j<U-M$*TJ1$f0^#PE,h1EvDA+LBXt$AC`V$lh+gL;F%T.,11O+]3:G+-Muu#,s5`aGi?`a^E]rHLJ'##Jn@8%Q/G12#V]C4]R(f)j::8.UD.&4qXr4)3[p=%_WM9/FWeL2JIF<%)CxZ43#>c48-U:%iL0+*Jr*V/c2hf18S]C>i%vG*wk<h>n18@>Gj>g)4'n3+P`(W-uV[*7:`ZA#V7LF*l@AC#X;s359Suv,gQ^a<)*c5&IbE9%:4%<$4]>C+qS_B#QNPN'p^O,2NJdT%>,''+Mm(q%s&g7/@X2kLfRWI+*KUu$P`,&6L/N&+-g?V%OCsK;2HYx#K3^f+K$=t$8-cY$blA^+4frxG@E=Z6r<mK)^*^6&>.Vv#QSJ#,jv(4'iM.h(pxmr%dwums@?rJ)Iigp7p?36L^t/6&Wwfq/ua/M)i^CK(M2p],$:'q%FBq=%$mmE3M<7o'iX6T.uo^O9YJk@$<OEp%2BSL(95A-)1jmn&?]4I)C&iN0[d0'#[,>>#oQR`E]Ux>I>)0i)k]:.$k&/L,0)h;-/k;U'GMHO&m6'Q/*uIm&?pOsA3N93(s(Oo7g+wTI.DF]u?l:u%>PtE$ddXp%d%JT&0QoY#[u&1#4q'H2o(TmA_47<-PK5[$>k_iBM:eB5W59G;_4ND#'o2VA?7<Z637#`4hJPR'T;Qv$BS7C#Lq[P/05Hf*9gPT.^9ki04nw6/@TIg)Y,O/MGA=/MmJUv-`I8n07XAnVBjSW7$cO-)A:f60WT49%s-320+?i,)?I/2'mtWaao5<oAer=;-rbfCMKAx8'Whw7/fCm-N*#E.Ns,/=)[#Dg(,T6r%t^su-W^l3'c/]jL<U;4+/)J-)/xJsA>'00)b*+'#kw2N3['w##S'+&#T>gkLq`_*#*[%-#V5C/#>&(,)#9+CQX;;Z;g-r(&'7Xx-O63TA7eJI&@X5+#-ej#*dL@<-#xQi&Dm_@Q'h_v%4Ebe$em>`&J;o.)d7(<-vK$H25C39%6ji#5ox*K%;ccYu/ac8.JU4'5H5_/)'oDF%'cO-)6l+G-#K1d-solf$8m24'd8-n&.TI-)0w_lgMi=p/s]MqL&ZL).Ir_gM$,J-)nYiV[51@@@-dxK#B[u##)c/*#37_c)=^_V%i]Z8/OJ,G4;#K+*$DXI),7Vp@m4T;.Vms/2Q`J>,]w_5Ol)(h$E4qY,6U`X-G#VDnDhUP82n5>?NtFT%pR35MYjL/)ScLg*PKY/(aO*C&OF':)1VrS%.1>0LusbA#PB'%MR=j8,>p`o0L^v&4>$('-U150L[w;mL^6iT7V&*<%_k26/kQ#x'E6.C#&=:g(6k.=-DI>:&2HU]4&,Y:v<4>>#L$M$#f@*1#ri:9/#&AA4+)Hs-OmaR8ui>w-Zu*V//,-J*sGp%@)=Gm'VAqB#jOPv$iH`.M>$&],D&HP0TMrB#Je75/WWS`E=9d;%As_E315-J*q%K+*$%I=79QW@,J-f<$Zs7Z$`w5R*1&*D#S>;v#vXO,M7pI)$k<S(6qA?S/LUWP&.bPU&vrD8&C9E-*5m)S0OZ?R&6FjP&P%I@-NgAE+b<P/(Y@1<-.+CJ)U696&qh;m/[08E+rMh-2q%V@GECrV$-_v,*(o'f)n<151KnI<$_a)*4lNAx#OLSrL7[0/Lf@1_.5j*.)]Svv$eeBn'`j?e)k>m/:9nT1;fVTI*6i:Z#pK.x,]'^:/TDvV%=g4',Pm-H)cwd5/lQsU.8x&9&;kSp%Z-8s$Fh39%Tsl3'FX&m&HFwS%D+D$#&-Wb$P&D`aw27VZ.F)##uWTM'WK]s$Dfn$$Hc*w$'QCD3QVsG2+K)w$(_Jw#nEZd3J)TF4r3]Y-ArZh*.-f5/8V?x6EHuD#q%K+*2BAL,bpvA#&i<:2)TID*w-ikLghkj1KC5d2kY*E*/7$`4>;gF4?DXI)Kw^-692pb4ZG$1G_I.[#m)%XL;U%],xfN#$cmgv$JMQF%gH),DW^Lg(+4$g)a#q6&1Y:v#442<-]juN'0<8*+SgL0(]iJ'+Kf*=(498=-mJux#Eg?d)_Jwd)(&fh(3+[8%R2MO'Z2n)*Nk&6&SlAF*bWkT%APv92>KA=%9(,M(fT2E4,VY_+AKQR&G=T;.XK%Q0@T=_/&vn1(`m)(&.@S[#?Res$]3FT%3uN]'L9Bq%Od++%'1pQW'CPj'dGnH)Nt<t$KhU&5p[G$,4eA@#4(=N1+=oT%ZX9T&]a1k'We.W$Vn<T%CbWT%0Gc>#81.W$q0%A,J3cJ(dY*e)kwn4(uEeX-76:^#La^r.1#/1((fZp.*,M_&8aU^#Vf)]-d/V0(W?q*%j@rV$pV$;%DC*T%&TWjL`HgV-(_V78aWOQ'Kv$)*N.CdQHl.a3G=UF*Gco=%g0LC4n=.[#E1#`4BA$vL`P8S[Tn-R*D(e#HAb'$1)bVLL%N.4+m=&3DfN.=00^J$.*<ls-I4/E3K7,709k^s$&7wK#I[u##g>$(#t(&N055%&4F?uD#;)pb*(:Km8eDY)4q3q+MH&=G4w[U@,FX2`%Y^J#G0@Ep%cO6D%dH<E(Y(Tu.xrxt%'7FH;<oeJ(KxZp%BFMm&tc7ea6iH4&w6?`K<bfxG<pjt&<fIN'jU(]$=BG`a%`UL&XEi_Xob'Y?[Zu`48*/NB2(]@>/:LB#U]r%,Z4u<MV^r::YT7k;8+ZW-j5C@lU#(^ue#]p%g#BI$Y5<gLZHx`<Tm?['2%VG[%[Bb,=-K.E@f5g)mZN7%vrhG*HxkA#:V-[KSW%pA*GI*[c/5##:aqR#hXL7#Rj9'#lGc8/+gB.*mcD<%.x+gL^J+U%o<SP/=V&E#;(]%-Zt@`,:Cr?#l:b]+/[2E48fd:.)sPC+3_gF*3k&@-7$wk([8$S/Jx5g)Bu5v&^@;mL6Q3E4k=%HFKv=u-d2gk9q$k>$M<q02kB3Y-.T'w#VGG[0j1%AbI/1A=jF>M9:**XCD#c58+d&K2BMnu><0XB,+S<+3wc``3Hlcd$xDKL=m2(-%j>X/2(4$b[Q`E+3hjAb.Wh)v#P%/:/D/P/(NY[s?[uC8%Xk3t$9]Dq%a>$5J^-x<$0$-02;'MhL3<<T'4uJm&NL)?#TZ,##@Z+_/Gg?C#X7H?&Qi%)=jJ<d&OJ&B+7xgC+4ljp%mq$wPWedZ&sF4:&mii?'Q)qa<7/Bh;72D_&P@[s$i#o@,)WDu$Y&P@@)c7(#%ujx@V4Io'mqPv,e)qD3,/6J*??@12cgp:/r-i&2?GRv$^^D.3O29f33GZ59+d-^5?kXt(n@n8/[j;i12D=]#;b3=$*>G>#(YSfL)G3g(@j2&+oS7v5`4:32Wee8%1b$'51f)v#2.Rs$c(/aZ1@gVICY(Z#^H9m&^`*M(CdH)*b;gsAurhV$=H4+58rcYuvf0k$=+o4ri&^%#)NUpL]$cI)[(Ls-tg0Z6gtHw^TR(f)N0D.3HJgkLAU7C#-T,=49Bic)YsHd)04vr-YmLT/k%AA4urOq_)f@C#g<7f3bd,eU%4_F*-e,`-sx:[0wiWI)hfNi(xu$9.DJ_/>EJ>?6Cv<h(gpu/(RH'U%@@@s$QdTY$ow9R'a&mn&Xb-E3JEB:%]@Y/Cq/c01?]xAJV97>%9AnV/Y$8]I?K@l'a^5/(DO%@#Ek8Q&67wS%BtJ2'?KJp&?q:8*#BG2rXeQ>#SI'&+xA>G2SYjv%3^a.3jpB:%Cx;9/^)B1CDqGg)If2JU=9l(7GHpS%i[,=&bDVO'Fhu,e4mP$-G?=v#@+6)4XS>Q'E[*t$'n?#v6m6o#;7Q26Nqn%#(dZ(#j&k?#kCh8.d.<9/$s%&4aaAi)F3Os-o0,M;O#gG37h.Y-1W:Z[0;nW%&Ea-0)%QC+BO(7'gttx>/F74'_A3T%p29ba$*ZcaL[brLe4U0Mqc4i,$^o-)hfL2:w`jYVQhS5'VdU0(?k'Q/?&5)g6IBw>?4_9V_WZ`*,Rx;-%/X_$m/e`*q?tQ/k%AA4[Z*G43v_20jAqB#X::8.O2l-$nekD#u3YD#332,)Bm)`#O0ug1*W<**AOTk1Be$^OkmO5&cn8^bg2O2(.PG81,m+*=%K<D>^<#?cq7I,*YuYZmvh=:&$rFr)'UVXM#dX*E*P@3'tMIY%fM?`a#&3>5j79p7W+v<.+dfF4abL+*.f&K2Yre.%u@Qf*-H;V%s$px=jZoj0>:oDSI%Qq&<bW9%vxh#K'maDWi5v]4<u$<$[-ts83+[8%me/A$F6u$.W71s-Oq/Q&MZW>h1>^2'[8a)[Iw4Y#a$#M;sDEX.Sx6W$aK:m&%q:$%F[,hYV*SS%4;Q%bh#G`aaF5;-s^*20)Q#,25Dr%4`';H*lAqB#k)i/<Rr(>7Rg;E4xZ*G4STCD3&ur?#6I3Q/B;aF3hU]=%Vl%E3gF&>.a]MB#f#5**<rOV&Q_+JE92*'4>^_s-m6A=-3@V+4gM/i1,Dpn/Y-DS*t'`K)u?QU.Yop6A<DniN'4ZV-d]LD?;-r&57->j-#58d;qD9Zd??(,)x0KfL)L%^0lM8f3YhV@,06;hL?&qR/>0%.M0]<<%t=&:)lE(E#$F`a4-2(kLY@+jLH.pc$F(XD#mxG=7.6#F4(GR<$(8HZ#C@fB/'sYxm=#VT1,-joAbT/1:N.2v#h8#A#ks+S/d32>Pe5(btW/U^u_U`T%oHHV#iE/W$bsoj'&ZQH,$MQ5/j<'5J^9x9(LPu]#TemY#0cT`NX?OP&RNEW6*AP##HF.%#Uqn%#ghc+#&7D,#Qsgo.gH->%/(`'%L1e8/[<W1)19xb4rn?X-P^?d)51Q,MkdQLM&u+G4h:AC#o-)bns_?LM7?HZ%EUW:.r6MH*wxgI*(KSm(i0$.)ZG9',bjK(k-J<9)ib#V#j-n4$dD(#$<YZD,Gq3t$9W5t$:%lA#wP8r/gnn21VhS^-Q0PD3;$O.-+i84'-7K-)Zo?`a*fA7-tn-rS$if1BD[.W$;klh2C0#3'D9_d2?Cd<-d^j:/M(A],l]KlLtiUh$X2>>#qqm(#HJa)#7<RF44h'u$qS%?Gs-tY-2e[w5o]d8/+:OA#P/NF3s:j=.%`Bg,XZ24'.0Yp%hF%<-x?U`$`E?@-Xx;c<J&:QV8C.=)[?L-)#_j;-;>1@-o$Dp.Z8Z;%cS&1,iiY2MLI$##%)5uuidcfLdd(X7Z&x.:_tu,*Y&#_FY=T;..'I(&l4NT/jr%&4)%[LMj[m=7*Eg8.$MbI)$67s.0d/[$GG2^#QKG>#[T+IH(0xcMXqZ1Mg'qY?9Tq8IN1R8%G>fv#p>T&&#:A%b:1G>#RST@2>@.<$tN,tOtYG=$lp0d28'iG)Txt5(>vlY>[wf*%9UikLS<@U7t_Ph#]5YY#uY8xt^FOcMbBAJ1m(8C4t(4I)xH2>&j9+0NCPZA##XIh&o:SW?ZkuN':1[`<*aWE*@OTk1];;o&Kn+A'.eF^&D37o[NYRW?+VRD&IW4d.m`sJsse]S##*Y6#9(V$#`IpU@WwG,*nX)W-=A6F%2x5a*7=xs-BA$vLZ&DZ+wOk.)Abm(5'Y_.Gj=<4^j7*;nT%[0)3=Pf<21k3G>ldZMY&:539JQ%b)qx@bsJU`3_J9G;J,?PJF;d;%bW,H2(^d;%Jtr?#Owkj1EHuD#NRI6/qpvD*RRT@>ubPb[;41o**axT%/u>V#$Jj=Gf7A9&6F,b#@62S&vPjA+'KFb+'woW$k'ar.8D.cV.0Sa+v8t//hg#0(K.D.$WWZ^7(7a9%L:nS%Bi:x%N^g:%'3X?#mCO_$doVl*;+p<--hq`$:u)T.H-4&#-x^4.vS'Q;w$dG*L0(r.gl@d)=Bbn2hf]+4.vOv,w@pV-r]$%lVqUE43>km'#i<<%9M8#%)aM#RioID*QHGN')eHU:S)cG8-O49%>;1<-80Dj9L8ffL$RaWB+YPs-?lmgN@[;+;j)B;IbgmA#G7K$.5mi`DDgZ`,A4L/)Ikjp%k37=-uImv#k-oS%h'&j0`=G)NWkoQ0_vqm7?K[*Nr=,h%>`Wucgk18.)_.*(B23,)MH_5:6IB$-Jtr?#@5%E3+0n9Dg1u<M[Upkp2pA'+7VI6021.Q/P`OsutM]2&i(Cl%7-Mn:UWpq%%t*MMAHqau5fPnFquv_#p@)4#2pm(#T%T*#EK0#$`)t>n@cd8/Ft#E3t`3v%pUFb3qEZd3lw*7/O]&E#+%G,M]&cn%Dp>Q/-:wX-/^%L(OK,<-9*J-)SI)T+4Pk.)N6.'5dCD(,BbNf<di*O'L9Bq%-2%Q/aTJ7/vZ-5f/U_?Q_<M0(td@E+DsH-)C6#(5;7SS/+aZ^7B?l(5cdDg<VBYN0xo=:vU%7S#(HqhLuQw9g4-W@,[M8f3ckY)4DPP8.F69u$k:v297'&#.k%AA4l/^I*DYr-4j:?O213IL2J*r_$2k&U`Oig87W3k5&X-r(E./OS7O8X1;ONM<LThA+g%SP[uf@V%GBS4&GBVIa+)%C+*]</<-N,Zd.&8E)#woH[$D4vr->;gF4mYUe$n]B.*LP1I$^x]_4'r[s$XjDE4+87<.U:>dM0@;H*W$5N'dL0+*pabP07DC00HHGA#vxr11w6)D+,au8%mWES(9[FU%9X':%EH8P<N:;Z#7_/*F'Xg$-)ncr/)RE?#3h-'58-'7/wJLB#$=P^$cO7W$<6#9%>gga<OS82'T#R90Lw`E[L,###fN,/LBtK^,dxl%=UTPt-4i$lL@`h)0&=_F*?7%s$M<Fn%d::gk'+p+M_Xqv-S,Jf3ldtG*^QM.0>m<87pKcr/uRki%NS;B#AemD4nU5C+F_8]=`dKq%3S@w#NAHT%NXK2'^Q#[$gEH??FFLd2iK9q%F]n>8Wma)+DClY%+ZPS/M--%-93dr/.7[>#Y'ff1]JE8&iFD;$aaYj'pAa+7<M`]?L#;4'gaNp1T*7G*BQ#T%W[$##,&P:vHjS(MTBR##HXI%#kd0'#8,3)#_=#+#TkP]4[S+jLSde5/nM#lLdGo5/d[1f)h;-$$9`Z=7x4V:%vl+G4cW1T%@6MG),qI5/-@XA#WO`v#&ur?#%S7C#ZB4J*jGv;%VH4Q/%wNQ$0Vu>#'Iec;mS1v#nYfYGf6BPSs(oV6cq-wp0D$<K0]u>#'I2c#rJKPS,P1v#C,Io#LZOVHBg_;$+US9CF&D=*?oGlLu#:1$<fS<n.eD78/GP>#^7E;$>Y6p%s/Qf%G,LA#uTd--'V75J.+a8%65+e#RT%fh.?VG#n:958V^&T%a*xf[&,###M0F`aPAUP&>7><.:E-)*:5sr9PfAuI6sUNt?9&ktt,HT.Y@u)4(Ue;$dcf;$jMjo]=[ooS4D1n%Yr?U%/r9A=S,18I]0<v5CW_tQLO]YcjfOa$0d[=FO^=;HsW[W$eB('#0n;%$YOI%b?L+DWvSU`3`-%##Iw%kVA&Ls$N]WF3b?xu-n$I1MHtE.3c?XA#Ov:u$PDRv$+G[C#I_89%jlwGVRkK(,2Pk.):M.GVYd72L:lo(4@@rv#^fx&GL*kp%#nB.j=Ojp.T.-%-Jlm92SxcD+2Hd9SY`J^+C-#N'=5C[0hYuu#586`aj%D`aw[BP8mT%##qT/<7dc)[K2VKF*KSD_&mEOA#`V?PJ&M:a4^NOf*kdCW-eE:ethtP,*]nr?#_2qB#CI;8.$`^F*85^F*9Men&gDqV(<aUv'W^w`%(fYiKl_2v#R':M'5n.k9hh%T1Eka;$OkW;$0Ux6&1%,j'_Icv,A*EV7O_Iw#T9XX$WAT:%`r&m&NlS60q-F<8mTc/2.F>N'aFg'+/NBK4a+F5&ukW@$QFH$&Xc]#,UG<E*tjTu$Ed.@#7]###$&###=98v#i]cf1@8d,*.R,gL1`Cu$?ArB#uWqhL5mMs-Xngx$/W8f3stC.3;@'E#G#vgl+AF.3=*AZ3QtwH+(7IA,E6PY>hU7<$LL:F*v[+i(lDQn&&*Bn/s:'k1E*hE#?g6R(g?:>?0ckQ'jo8'+;h3u-nbp'+Pge?$eK_^>,]lE*_:1hPQ:4a<f38N0tD-(#_[P+#Ist.#44B2#bQD4#]lP]4MFn8%x3vr-kZ*G4[`JD**^e`*R+AT.N)b.3sV/Cm'TS.GAK.IM`V@C#@IwD41uSfL$1<9/Z3f.*7MYS.4?3-*F/E4;x?lBA&RmRA8du_FFRDT/_4pL(nMTG.B&>c4<gg/)?<@IM8T*NL9Yl>#Clta$3S(v#MbEt$Bb[s$ZdtP&,V6p.RxXv,$_^p%k7>O2E#r&4?s&q%=pY^=OY+Z,dI@w#)cP>#juZw'mg7_8]L<9%[%7s$C-h8/]mK2'/.B$R:k:F&QWu/(67^H)M1I2Lv/Ke$Zkx2'$:ugL;]Yn0ekg`NKqhGDRC$(%9SlYuku1Z>o*72LB6wC#YXes$o5$E3`b-T.J4e8%#pY3'B9T011.9k13O=.%pL]=%L&h8/@5CW$fnllR8s't#]9rk%GNln&nRMT%^`%h(1ol##;Y9+'4CAJ10j3GD5-wbNNFU#$*GXV9Ss@a$f*eF>FCF+3GQR12_V8f3&cDo%wiWI),`>`.kGGA#%U[1MdxCT.e/ob4HcqlL*bn5/jB@1,s$i^%xZr%,mKn0#mkjp%gNo/1s4O**D*kT%txC(&o[x/(c,$N'+5-F%4P<qI7M#?)K4AU%2+hJ)f`rM1Z8Z;%_aU1(Sn@@#j.w<(Z(dWI*Vf_4&]vP/Ppc'&X_)D+^s#6&[%h##(&>uug5wK#Dh1$#_69s$kf98.hl_8%=V0f)MCr?#a',V/HS/)*P)(a49mcG*SSTa#`;E.3NY8a#]'%Ur+W8f3$t0<.]Xfm0TvPs-lY3a*Rkjp.[*'u$mHux'#.=G2wd]6aAIf<(S=6>#taFT%r,vN'l)_Q&%=m_+;bfM'.]Cv#tae=-rqQ9.dB49%I$:?-=gNJM+n7o[kMYb%MYl;-M@`9.0s48R6DSj0OL;R/)U8Z7<?Q.<Dq3t$+k]n/5`U;$4lL;$ueXi(D99U%d0Xp%SPC#GQVRV[Lmt;-'`q0%^feGV6Yuu#2Z4f_j:@]bh*.5/p(/x.4[lm'ZY?C#L8-+%Jeu8/)$fF4Hv5-(9_iCHd;Mo&oJ_Q&e_*X$8boj0Ysp:%p)*B+wOk.)Hp.T%^j-o#+<]IqPdUg(t'uq&hN/W$DBUH2QHKU%?=[S%K]3(M_65)3%2Puu:g-o#,XL7#fd0'#9veeM^f'E#g]vc%vBSP/V)ZA#9`x_47WnD*^t[s$,m+c4F2&v5Ku,Z&^p,n&4?/E+F%V52tW,F+`v^Q&Xb3(3/x.*);b/%#2@Wl&Mm&T&I[rX-FQxB/K&DL10ogd3&'hQ&l1N@$bB&r.`5YQ%3_+/(S8NM%`kfi'Y+pu,LIe22_T=SI7qv:Qh<YxX@L[(aoh>fhjc;F3Ai:8.6PL,N2IXD#FkYF%H*`hLClP<-`?S>-H-aB%]d6=.wHeF4r%`W-wO]E-@Jhv-+Kwa-N)G-;TK&<7dCXI)^mOv-C+%+OOCRURau?X.DR(<-e`/,Mk#0nL%MJE-B(mYu(o0^#$hgL.xS&B+Ww3t$GWeO]*r0B#C[*t$;ExP'UB;X-Nwv--D+QQ8k;wuQVgA,3Je:B#<M)aI9%6s-ZIo=B0k@&GvbSq)&19ba;%mca*8[w'3H6R&Xa96&tv:0(M4t>-q<qDNopB[Q#'_m&Z24CO`_3nL&`$##&&>uu<4>>#H*V$#mCS-<jt7J3w-;a4MV&E#YiWI)P3j;7d>qi',bZv,`,b/2DpCEMdQ>V->cxX[:_.D%Fer65T@Nuf)3(B-$aoH-;L1hL&j,t$9?6X7qUZt-Kh9G&ga_sd`WOv-t`U[MIwr<-'>cuu9^hR#F[pD337p*#7I?D*1h5N';f)T/CI?S'#34k1Nnpr6Z&PA#b>q:%tCBv-DcVe.IIV@,^Kxf$t^v)4.#jQ0S)ZA#K;gF4PNwV@t$7,=AsYx#G+`;$MTuJ(x[0T71PY>#Ko`]-qnn7n`:%97tv9H2e%bI)$%,.)[f0#&e_c;-:&i-2^S*T@V5do/m6Y44LG`?#e;*qeA$5/(64.<$$B3W%bBAj0HS?%bS=<2ql8#oLU@9`=dD24'9/83'UjgR)T`KkLbI<mLvGdo/p;7Mj>hX)#k,>>#M%p+M,(w*&3CQv$+nTb,C>%m-5I8X'aD&J3lk*H*g3gA=-L6_#N,]l'Sk39%EFVj9%q;Q/coAu%%aYp%ekAe4UQp6&ffwH)p6+9%@J.['L9Bq%c+(x,[3L-)8Pg34b^^p%<`qK*vXW0cr?.<0%kuN'PNGj'bE,j'IJpc$x5(6/&XL7#D[=oL69YI)B4r?#+o[_#<=YI)hk(,ARns/2_V8f3bP>s-^J$ZGTMWZ6m('J3XO_]?44)-*M&e)*LV<IdF^c5&mLka*GDQ'=A^Zp.3rF]#-6ns&EIM;$ovPJ(J-t9%LJ,B,pUv-4PWl>#Fe[s$w23[gp02%%HnA2'c-<6/jIMJ1H=G'fEbrU7WF,n&M+^m&dh3508_J2'`gZn*8'Id3qmT1;KZPR&[:1<-w9w2M,xX@t-Nsi9R:FD*i+;-m''PA#6bIb1k/OH*1pTv-eP))3cje&m_ILp$/<3E412eF<%To/1wa_U#7F39%NL=_R-,NsR8iC;$2boQ&5O=Wm+m9/'Zj#n&N%lZ,Ou69%=llx55.jY#$cM^4O(1a76HcJ_$<3X&_mgQ&xMLsdbhq]lq63j3j4SeN$&###0W$/Lu4er?l>,<.SZZd2YiWI)RJ))3Z3f.*`69u$[Yt03Bx;9/b-GK.u3YD#ic:E43+gm0C>^'/Jf@C#kK(E#ol^,3C^EFN_6kxF_T*:MeS&T,>vc#>FqjT%XEB:%V4P?,#m5:.&]5G*4+BPTdLt+3PZ+?-_0aY$f.n92ahNp%09_e*O3k5&n`R1(<*59%>^KpR@RHc*=@G&#0n;%$kS+##<rw.L[=PV-NO$##04cHZZ@[s$O+ENrk]0)2SP,G4tC,G4DMn;%xNh`NW0mo7AK8%-eS##-YJWo&@6g7/'^H6)FZ.L<`ekp%BG#W->LjC&;xuU:C(C5'NA8L(Z*'o<lFiIr6O830itnNOL,Y:vi>*L##*ChL3jVV$:tUhL^3Z[-d.<9/pk4D#]x8l'P,/J3T.m;$Sr6%bC:`;$SAV8&&*FiCCnnr'CX*9%LUw8%*.LB#N]kH;.HQ#@&bidai%6D<#1fu>Kt#??I3V?[LF3]-pf>W-@]S:)s)9W-OmprK;UuV&cCK,3Qe5H3_)7&4R6e--6J&/L)Qu-523Ko%M#J1gI6?KDC_39%^jJ3MPV:@MLs$F#JiuYu:D-b7Ph++Bj/am/Y`$5&WFA`&fNl/(PTjs%7`n`u_A9g%b5Q%bhuC`aRW@M9rd%##uqRT%A;aF3H<x;-i/=0&.d%H)px'F.7%G,M$(<9/7ja_$hx+G4]p5%-xdm--Q,Bf3/G>c4F`x_4P?L-)LhhU@AsI-)$mI4;.<7F%s`#[@qEd0)@&RJ2vVuo/a%h7TX-J@#AYS?5QHGN'e:T'+PX3Z'>C.=)[p.'59X54'sUO>Q+p/gLG_?C+MiMP0BiR_#D'x]%Pvs9)gP7w>EY6),^5>##)@?_#O*[0#EXI%#Rqbf(`&Iv-*Rlf%[>Rv$D(^C4-9]+4O&<+36@O;RR>]>hV]ROVlJ]Ni/nfI_ofY`5>hhN=RIhc=RV8'7=C^5'<kY6'nvtM*EFZi9P:hB#0YL7#?L7%#W'cH50-8x,?15jBVZPs.X*r-M+V@C#R9Pp.ikkj1niF0=L@<9/h?=g1EK(E#QuSfL_eVS.V5do/4qZB+cUU<-Nj*.)<OC>,2&Wm/C,fH)FJ@n&g.Fa*E<,n&W6fl)qRbm'o=J9&[tjP&8u@n9'[+A#pRCp0(#O=,keL@,9kl0L(<_s-/gi[.ks.hCVjv`*rxN7'oJo`$V>dV%_MHV%(#od)dt-lLVn[m-M]s^fl,<A+ers22+%Kk$o*'u$6Ou)4[+`Z-<)]L(:ap*%1lh8.75^+4Bsfe<4D,##N`RM1Ws;u/[75S-kZFU%lOs^u5N=D#eqZb<2p4N)59b7/q#FB,p.k+*.J6>#,_Fg1qi;'#&,5uuPE'Aba4X;.C5Vm/Vapi'cQ+,2C$mN`&@o79`ZlS/G2-<-=14J%Iej:8<OP8/3L$C#=kCv#FRwW$WCd2'*4$?$,@.JQs[qJ-kBX/>re;Z#h&#b%3<*Q+wOk.)It&T.>[<t$lfH=.4kX;$30o5'AU=BQ_p-Z(UqT1;UH/^5h5mj'v*AW;(lX&#Gq1oA9LUV&)Jl>#k%AA4a2.l'*0^]=?26q%OFrZ##Ge2032GJ&_^0q%:uq*%H>uu#38i20NB%%#m@*1#mjk<8viYA#R4r?#PCr?#m)t<:CI;8.s59m87UlS/t5Uj9*RYd389v;%Z8v?KT<SP/Xqaj0YNwb4`jp_,#TCD3pc&gLCJs?#;jgO9]FKdmo-_n'@%<9/UTpx#L?'m&EXRs$SKf[#/Yl>#(YP3'D_,12vR39%8bRg:;T=f4T-X_&>1#W6DjHN'%WQa3'H?:9stOu%TB9q%le'9&W:P$,$hk9%;B<Z6$g3(4Y:)39UNcvGI.Rs$E@es$C=)v#:32_Ahg)&+m:@W$l&9hGE=fBJ.%5w$TYs`'J<,3'3vdp%5ljp%_2<g,(4w]6C1';I$YIq.92g2Bs9a*.`SpU'C9Ka<Nl'L;,vd/(p%tE*,$sL)oT_V%Yp9<$><>A:<+iV$/oq;$-;e8%.=:B+/5###)55uu&e_S7Ve##,ts&/1>40;6D#Dm/hB/[#dsUO'mhB`$o)n>%%wb$eme)+(tfB.*0Zc8/5+V:7(tai(^tET%IhI[uv?%w#97@s$,AP>#twAq%7n7K:-@+&Y1v:HK:WS@)(e8?ZL?*D+Wwap%ivPR&T9'U%rOF.lw`@j#8N(SV5S&LQtIes.$WQXfwn&/L_Rq<%J*e%Fi)u4J+V-^P,nw*3sgD2/'H5<.9][KsWBo8%k,*M%8,g&?Uqb''k3-NK+$@L*pVPA#V9@+4JxohEobp>,7C8F,K)Oc4a*Ig)8vAh3xMI.<hVnH)eWL-)>H<`+6Dh:'?@e8%SrOv,GU7W$VE9q%uj1k'NNCg(U0Ss$='n;%9^A+.EPP$,-9dg()rMlCYb3X$W9#3'XW)32*LSkCAq/.GY68d323R'As$J@#3#[E3#4:r&A=49<i/l7'HU-%,oqX,MNiev$TW96&sYU#v*8x#/r<t,BwedIM/;s203`($#Pe[%#lj9'#a,>>#7btD#n,Y:.CiLs-?D,c4@DXI)W76J*Ql`$'M2d8/[4i8.uiB.*DomJ:?L(KCq[=+3v(tt?B=Us/DQ)@8(B87;##>Yu?'vNB8BPL)T0CG)'g;4'E:,J<_(Z7(9TnT0h>;@.A#iZ.<V(i)ucY%$v;6&4.$-Ak90V80ag3*,HA)9L='oK);-=Y-(7l0(8bb?.xAxK#)?U5%u1Y0&AS7C#Ree8._2qB#=f-N(MUI*R.X^:/x1gb*]%)<-xj?i$'[bt$=t?8'$SK/))pw6/_Jes.[Ul(NHwb9)RubF']gYn&-RRY6jJ24'/4K-)?;XGNgkA44_rL5&>4:;-kt&8@73i.3m#:u$X^%iLc?5H3gESP/-$Ff-pv3kOn=e8/MUgZ-NP,G4@Dn;%@-'T.dOhY,^hSV/4)V:%?1[s$-FlT`#>rB#3FS*/Ka.Z5WXTx$W=(<-Q)*E*E42?#)WSZPC_39%1_QC#>(f[#_1tE*ZCL<-5]c>#nUC_%2hOp%FaAF4Utb,2o+1U'ZO_s-[+G$,.+CJ)+i>ca9;Ht7.n9Q&`Dig(=HO-;?Y$9.dljE*Q[Ep%#IUN(J4Si1lqNf4*-l5&5?$3'2)do/*3g%#A)sG2H,78#^3=&#I2.l'X`D<%qs_0%9`Z=7%`JD*5-i]$Y?>V/3(W1']ggQ&VVP$,sIa1)BfFhUR<#K;[2vR&OdpOJq$,8IwmmJ;7A,I-px>)4M5Pm'd;[gL0x;Zu7qXJD<SF&#CM-T.R0;,#lu)J%M+3Q/&tB:%jCh8.qMg`%VdVa40e#;/.t`.3h3UC4jAqB#ef6<.?=Vs-ZFq8.*W8f33lt;9@r8Z5`'ikLZLG8.%J:',$6nn9l;Vg(Mh*T%uAP9%XA%h(47;X-DG%@'*6I/V`+Ow$u*qf)o?u`30M@q/JTc]#>O?)4:vKZ-V8G>##mFo$,qT&,i:8R3lk@w#bEK2'*7wMM*e(q<1Bed)5H+u%Z+2$-u3B6&&ZK&,DuEs%;Gd'ZfTNmL_;^%#KoA*#*b.-#U3>s'bDdc2C=rkL;/E.3sZQp-:b%njnkkj1D4NT/Q]4R*vn@8%[YWI)apd)*'4h0,*d0<7`m(AXwesD#HYt/2fPXV-v0d%5TL52(_fiakZq%j0w+Is$XO:@,urQ$$wAR3'I2jA+Z_p,3fp?T.9%`;$b5q#$=1K('@v<o$h@O/2ho.21R@ml/[q[p.K%.<$n-1,)<tJj0nr3c#?*#j'jfIi1k`ah%&'OZ#'4Qv$(F0F&I;G##G_Oj0l&U'#S7p*#mp@.*f<Jp7`fHZ$lT&],@,h;-+$+,Na9j?#&kw]OSttD#%H3'5Cc@%bDOOk0>v,m&jTR&,0#TDX63o5'733FN@$+r.2VOS7j;a-69+O01;p?d)C1M@,C;wE3?()t-49*'OC'f:.j/G&##(Qv$BOq@IfTE$#hpB'#JoA*#hb5A4fL^Dl']7C#MPsD#iPcD4X:Z<-ojE?P,rVu7<e/9]v+bS79%`;$)V>W--/.A';X0A'`l^1P1lN+Px3&v7A.#*=WdA#G^(ffLRqVv#E?UiqW0i$5*P(vu;m6o#&_U7#-oA*#&Ur,#ZG_/#J%^H+r[`V$lJ@d)0xJ=%fpQ11t:*x-^No8%%7gx$diw^$he7W$oB^@-wmDB%sABS8,IJ2)1G8fL4fu>#t:iZ#<d#9%;4bP&HR&?$PSZ/;H/5u%1QA&,Z<8PB60B7/$P#C+glCQC$Rg%'hOj304%=`#O-S[#61`4Fw_JF+nlaA+e6(p&0F;D+m'A%uE_aS8JQ_s-#as[tn;@DNq1`c2&-ViB0[v:Q_tu,*aU)Q/?7mg)l/Y)<B'D9/&_<c4Jc7C#-X>j0m#:u$QaD.36pdA4r>R,2],Qv$_Z-H);cJD*wg,V/Y&'^XA2I&465k3(Bb+2Kbc%5';+.<$4i_;$v%.cVAH63'npcj'-h>F#?e/m&;Fe8%0eO5&D<5j'v0OT8MZ$o#HgY7&7IWP&@JlY#f:Nu.SIrV$k%G;*f8eS#j9gvJ#CQF'UdGN'BeEp%[]u[0Y,aC.mObi(pAVfL(iI9.?BHtLg-lJ('*.].Z=.s$lbffLZ6<Z#QIV;$;:`Z#QGR1(Nal5pTS]p%)D'i<wOO&#Hk+w$)B62't;Yc2+n^o@K.h%FG;'##js:t%(VFb3J^D.35qB:%bD6C#NSGx6K[vLMg?j?#`htX(T?ng)K9;8*MsHA4oQW@,bF]fLD1h%%_kL'()Ic(7$2<,)a'49%Tx:?#<<@H3Lq_b=.nSM3EqXt.?O5F%DN`'>V@Rm/lURW$bsdD466DI2W5Sh2qs`N(fU&Y.xfAa';^A_%?fh;-%vtg0AuU;$SXQ@)72^kLj?*?#9OM:m/XQg)VvC,)GH]49YFI`>F/Bm(Ft/6&,u9X6f,c;HKNkA#D)>593=`qSajuj'Yj,r%u@fP'Ax$W$_(:@/s<T6&ML2MM2C%q.7xq;$1emdb9iD'#;8E)#n,>>#^7^F*jpB:%?@i?#AKA_%:G>c4S#,H3Di^F*RuDe-v6(f<BZuS/Z,LW.3Yr_,d0]T%RS7C#K)'J3moGuutWo<$jH0=8:AD(=)Hac-?;P>#ViZ;$8YC;$:q4v#?lE@;95k0E_Z`:3qe>C+c9xS%@O<p%7i1?#d]4pL&LJ<$+eemL_E+Y-4=<N2+/058*2.w#r;GA#5D>YuMEw]-+gq_datFX?dJf?$?UWp%-GY##F$sqKa<w##@>N)#$=M,#KI?D*8^ZjDY13C=af,g)=Wk;-OE:-/doJK2xSFe-2Fh^#u3YD#$WMV?L@Ib4[.5I)QNv)4-<Tv-M):I$WHSP/Vl6g)ir;J8B6fY-ENx*m@2oiLj^pZ5-?>40SQ9q%ZWk]#234Q'Dv7iLe(4[?V5do/3V$%M+M34'I@%s$eEO=$8964':OclA3*Nb$1irf[=(;?#[,q8/*t+`6P=HlL#<Cq%3`H>#;8ip.e;s7/)rI9gYEKB-_=ClLicfh(t:8l'jlP-)&_#x%6N+##m09j0Q6F`a2wRc;%ro,3TlCs-c3q+MJf4c4)O`t(ZU&T.hZ*G4HU`91b2Hj'D7S/:$pH#6xGR7As7eC#j1%<$68[s$(r9x5?*G/(Kt`mLMNLnJi@R[-dTP3'`ZXt$H^&o8`gG/($(cn0N_Hu6?d)B4>w,mSD%T2BT5_SI(YBp77Xg$-BxO**(fBf)9YwTI?;G#-u#.L(_1R[-6j)#5<es6/&DJfLZ'@##[*Zr#``V4#(8E)#)->>#'TMV?_hc8/mi12WIR^C4+P-AP.D;&PCttl&bmfx%ZTXp%:;DwSo41mTC;#UMm+^j2=1]b%h(sb,W*xq$&N`)3Jrn-%/mWCQC_39%=Yb_&KorQMO-=IHWA=<H/M@6/3eWC$3^+MM)r6u:`u#E*VYr$'M&N-)&du'&.LvA5f:,Z$M:hEkGS2GVNrkr-^xhx=pLF9r+bQ;@<$$Z$rp;t)0)0A%M+]OToE%9*Z^A.*dsUO'%c7C#vs'Q91P3Z6(COUIA`Zp.Y@H;-MW1?8Nt'duh^L;$TC[S%Pg0>$A'bX$F&*a*F]u>#@hMs*lj^p%EBAx,'O49%T83aa0gv5/]8HN'=r(?#;gp;8d[B_#HvD&+F<t=$ANUG)HY(Z#C%M;$ZiXtZG`d'&S%rR/oQ'd2%n;Y9&Cd;%0*)t-jkn,;1xW3LIDmi'r)#,2kN%##--l,OQ8#s'Jr>a*<:as-5(Xg;8%^G3_5,W-:T`LLB2eg#P)I9M<aG;-*,MHGAv^C6E_o]64*;s/V+mC+Yobm1^ok#/8<H+<oc%pAI$M(&#q<]IQ75R0ElCZ@=EK88>qcca&VNJ%#06s7lPkX]q1Fa*/xFE3+gB.*n4^+4=Z8f39`p>,SiWI))OF)<bJ]manuCSIN<XW-gc3eHW=rKGPg*32Ng4',o<:h(:ppj(Q9Bq%KZj1M&Sd3)(f>C+'$;-3&4@g2F.:$g[2v92EKhba.+CJ)E4hZ-IQIl'=dtm'rkcN%:W5^=@WJ2`5VIeMor0h$nS2GVnZai0/h7E5CbXD#EaoA,7iv[-90c5/<DtM(p-_fL/4(f)NNXA#>)P]FL;h^#bj*.)sGB@MBjSW7N1D?#:G***sTAe$?uu>#-c%[uOW@g:g5>b%T<FT%fe+9%HVLHMTVY8..:9U%wpLY7U4c#%P^U,)u3/9%S>AjKTs>V%f)vW%i+O$%8vaS7'7*/1S6KeOmOVE/&Ql8/KNE/MV<j?#b2;]$DV>c4Bl$],+.`5/dbL+*]**>P;IK>cXv1)3=Ce8%KFs50?tOh#Lb)h)BRes$,DKB+k>ZG,0x_5/jYg^+I(2&Pe=f21Fr8e*t=ns$S..<$/E7iLmo?3'U4u;-7iC;$IF*p%ZN#V%-I2W%wxG`/r+`c`ArJfLY*euu8dqR#iXL7#@R@%#0>N)#-$jP%0)K+*YCh8.Fe75/YcJD*FMbI)KH09.G,;u$<`o/1BkY)4RWgf1-R$v,VxG=7)j)M8H>'32*;]W$]GeH)q5cp%2>2s1qttq&ZxSw5i'))+2P#N'#w?JV;4lQ'jFoP'RIqZ/&v=;-<C712eFUh/daXT%Dqh^+#&bI3xM/W604'6&CWB?-a@W8&%](w,%Sc$,oYUY$*hM`+<ABe=>`:%MG3A(#J]&*#ogwX-PP,G4jTC0%3jic)a(3:g5bgx$nxY`%n+]]4*kH)4mYo_>N#b>-a6<b$U%6+v5$Hq&`.?C%mp'H2t,+jLc)vV-g7pfL(F?_+Get.LhGi7@uS?T.]MAC+eW+A#o5IrA]PwS@Z8Z;%ENo*5<#PY-Y:Bp&O?,3';bEN0q/Y=$Vt/H+^2SVM-gq@-.2=i%TDluu001n#*kh7#BL7%#U;x-#>->>#D)MT/S&Du$,H#g1`V&J3Di^F*g&fTi@)CR'3eUa4m#:u$i.<9/i2c'&2MbI)0uY<-'Dg;-$-UW.<E6C#/rY<-LfG<-Fb0)M1,V:%iL0+*s9uD#/Y<9/FV'f)(LE33-qYF#7xBJ)&VXY/GLNrR-tkP&O'Ft$b<Sv3OQgQ&,&2X.@b2M)D3pM'EW4336`xH)O;bG4(f,(+N9Ts$7?oE+E&Fn'C4rZ#PpJx,6MHb%mM+N9#J*A-<@R<$G`u4gV5do/Eda=&oo7L(U4)ZuxWP42CBQT0nulT8UqOe<W<dS-s7@W$r$D`+V:^r%7.i?#xkT'+x(8p&52Wm/WN%PBdZ?V%F=[s$?eFt$wVAj2Ij-H)'E6_-NV=I)fZkG2LZ$v$'VBh4hF$##&&>uu1:G>#Y;F&#K1g*#$2QA#W?+W-=rf;gF:=+3FH7l1Juk/MU#qS/*_Aj0LNv)4]m3j12Urt-9e-AOSY'gMKqml5eJ+<6`GhX'voQN'SWAY%]>7L(.@Y/%Z8Z;%t8[@BCe<9%+*`['`o$^=l(%<$%500C$[;v%q2CgsSQ^6&i^r%,b,DO'oYZ*3%'s4%_pw5&uh]gO8=ns$$vdqAOg.A%wr7Z51;e8%X^t5&Y&kca(7ni0Evv%+Zt$##&ctM(cei;-NA9j%w=PjL/TIp.(tN*c,nIm%^CE(&x2$I%CZ59%no'HMKvX`<=cOo7^+6LM^4eTM^N&@#Pd1*MDJ^ZN;-)WdnYtJ2YGfJPg][`*A-GTR9Ww[-u?lD#m>:Z-Q(DK-YE4g$6D`p%`7xR8urKATf,pXuG8-m&]Err-$6BJ14Ar%4L3DP8:E-)*$i5m8cp_E4jhtD#aGUv-u4E=(w%AA4P)V:%i@+w$&mm]4<i&E#_YUa4Xbx:/QRPn*,l[s$8q,[+&:G%XOW,7&]tJm&Br6t$NQgq%&=>gL3(f;%w;gr.kmNRUec@1(f*/2-G:j1-Ww`xL`WL+=rRx9&^*av#ji-s$93)>I(>W/(0q^u$x:;S&Le*=$9LLB+-D*f2Lpnr6jLN`u)?qj(LH:&45F60)]11h16Xg^'Utw8%4>###6?9-m[n;##&,jB,ML$##Jn@8%6f4$ghg$H)B(c_$9hv1)e/ob4s=pr6R+h.*#R+,2cx=c4nRMM0Gc4i(JiXV&ja0d2sx3=$4VrQ3E*Bm&*[B`=xGrg*o<,W%7q<B,nkc,*B@.0)Q/.n&kv'd2#PNp%>1@8%k_&Q&D9M/)pbu?,xD2W%)mxc*N&mD/-,Y:vjtRfLs/W'#T=#+#3b.-#hxQ0#JwP3#Itgo.l5MG))HG'ZaB3mLoMXD#4;Q`%-a(Q/BsMF340_:%m2Gt-*F,gL'%2x5i_T%%0FY=?GE<=(+WA+44x8KmEvNbNPPrB#x.TF*lf-F%_#q?9n5jG-`YhV$=fYYu/r@@#^Tcn&>mZp%4>,##1xRpA8nI[#Ff,p%qoN0t]W49%J2VC&W#fta`eV=-qVh<.hV?g%5p(d*dvaJ2+$%79:AtA%O^U,)@,1W$xVvQ86Y/W79pJcNq^:-OIp)F&k3.d*l#><-9XEB/oxET%<32mN``[iNak$##'&>uu54>>#NN7%#9Pj)#+e?S@VRN/2enRAeG(<9/cH1P:JiE#-JR3Y$nnr?#$rh8.rsI,M//)69U?d;%ppj3&[xvY'Z_7%-Z:WN'$*olBSJN&+]]*b-+=/$l]lH4(T3N&+h`I*-e,_6&fUgQ&]PC(&W3;O+gv,mB@r*cNU&l?-'i2=-eQ]b-(g8UDJ93UDuu[fLVcCaN8,%##'/5uuH,A58xNWS%?-,/(*xBP8Gf98.]e?']A.Ip.qP/J3BO9]$Vq'E#GqA8%&U2QA$Wt1<(vJTA]Oo/1unDZ#2fClBLtn@#-Y?eKjF'PKjLip%LE9m&b8%DaC_39%d*49%RiuYu:X5W-?:':)j4)Z#HV=;-n)h^%4n.1#g1KmA96ebl*@i*8j.ge$HX'44]2oiLds78%ro$4Lv6[V$H;sx+2x+87%b#5AC>tv$aDsI3Z)i1.1Xp+MXa9x$'M<9/a1[s$W?iwg$K@d)jq(%IG5;P-%9@Y%jx=c4H),J*Zj:9/I)MT/[YWI)JI]C#:;.Y6OAgN+^;-n&X0n`*#]15/`E9Q&=)>HNM$8>4@7oLlkCPd3SQev8]XC/)X5dN'<W8<77rWF3kG2;?(1_Tr.kms6j>`fLn%,.)oTex,N@)w&F;Re4(6B4tSQ/pA=cV#A''Y72Y@ZkgAo.;%](K`$QpKR/'`UNt$i''#QYr.L2Cp*-S_j=.?Dh.$Sggs-3?-/EP;,H34tFA#RGHs-X[sMMK`f@%mp'H2_bh&lkIA=%6xmo%8%KgL2kAGMe^&l9DN=_/q3n0#f*axFiSXFbCOgr6#07JCbdXoIiB?S'X5MG)e[EgX6[XD#[q'E#Vsg*%WV#+Hk[Zx6l])]$Jn=Q/P&Du$N`0i)+Ye+>(I1N(:tu;._OgfL6?Dk?0+Y^&(br8.mGUv-jUKF*P7sv'/u]G3i6$h(?hl>YdD24'us9q%d__<-<(Is$G:rZ#Y-'m&G;>^$W>?v$A47<$gEIA,(@dK)OXN-):R84'ik:((bn'hL$nVL)QNv`4hI*A-,Ug@4iv,n&YFP/&i@9f)_G(;$_5dR&7`[-)I4D<'cg,3'^P<E*CZ;E-7cb$/En8W$j5EtCRNrhLl'#X$]V*i(ORD)BJVl0LN?;B#oe#nA8/ST%)85$,hX(712E_H2NtaT%<kAQ&n.e_#$voXugd(,Mwt8>5L'do7iu7#%>lm=7uNi8.Ff@C#WG<g1a&PA#aY?C#kHuD#,^4Y@d5Gb%>>%Q/YG+G4C(=V/h^Np@(m`iK-Rke%Ha1k'n?W?#T.TH)T*Ls/nN2-*H4Vv#-Rev#nOb**D(1+*M$vR&*:RE*UddI)@YJ1(Dw_<)5=)8Gg+e9%vM#T%aKOp%7H@U/e<mj1Fuqs$?(p6*W1V8%NhNp%#?'v/%B.<$:kxS%CB)$?^oqs$xRYi9<EVk15D$##$&P:v_@P>#*6i$#9,>>#vU`v#x&9Z-FkRP/aS&J3,<xX-'$d-)r%wf(=k>.qdNfw#*$ik'I*2]O(2ED#<aMZuKk.P'[-&@#BldU7=W;r7&bbmB(I;VQ1mc'=#16Z$C$L5Wx8tV$g(]]4jwRu-g7+gLpeXI)SSjTB:q'E#sJ))34G5s-nM#lLdDe:&O*GXptq0+*]wt#-XsFA#d&g*%do@A4d'DeMruqv-/ugt6K%Vv-O;em0rT81_C5hw0PR(f)BA$vLPgtA#X/6G#HH'#$Sju/(Fu_v#kIvl/I3bX$SmP7&8%iV$u-l3+/TiS&];6?$UrX;-8.%w#m0L-Mh81q%W0]8%Yrv[bUfu>%r3Y4K+7l4'KEgq%%xFq&l/hQ&7Dt**cmB:%k&bZMxKKh=`AM;$o_W-?cjXp%D1Q>#BRj5&Jb[8%TbNT%S09U%7IWP&=CIs$BREp%;I<p%c&9I$k*gm&Y&h>$9L&t$aCofL/hD<%ZbsXc;_F[$o.JT&lU^B+qSrK(>fY##%/5##0#od#D<F&#Mf.)=b8^G3DWBn8^]HG$+xQxkIPv29?+o?R0=LmXrVcxuqv5V#kxc;-niHI%#f]3ir[=.)naeDN7r@QMQLkB-vbKhOO;^gLZQZY#0gtF`^(D+b,s:D3:E-)*M7%s$b(^F*MFn8%dZ/I$+^Q_#[C[x6&rU5/Hi^F*rY5lL:/^I*sj>T%RJ64&js4T%Q5-X$v@oH)I4D;$sVph=:v^7/Se@s$J59M)>m9w#&1U^+^>4A<P[45T7>s20g[/m&%#^_4_Cr;$3k%*+eVwLEd7d>#gDVO'g<#N'LI]s$douYuJ^8R3O,GuuY'Qr#vXM4#/f2i-kaL3X._E@&e0f$7Kq@8%kE>V/2Of@#G*vV-hj3X$A<rS.&1U?/b]`V2-3#6B7=D&/@Iwn$@akgDv>v;%hnfAQhMbh+M7$##(8P:vN?'Ab[=`rH8B&W7QRsF,eGse3aIcI)QbADZcZ]s$^tn8%?@i?#4/)(&aOu)48Zkv6pI>c4Zj:9/)u6lLbP,D/#r[s$*r+gL@.8C#SP,G4er)T/1_v)4u<7f39Aw]-aZ3[9fWR$9MsgKlk2d=pK(_gM+Yf`*L5*E*SR7w#;:R8%GH6u%Q1mY#]1^F*xhnB5SL+wlLpH)*S^nb4;Wxt%B-gQ&E0tp%.ZHa3n(`v#GM)H*omd.MR.N`?DwPm8BP_=%:rH8%^xWE*L7`?#UQ'Q&I-u[$;.I8%_%ka*Qh<t$1XV#PMma_5[fS#,=_W9%oc[H)QP3.)04*v#<R[W$Vq@:.-8###TYDm/Eu;]b4MR]4q4*j$R4vr-'2h8.lwkj1:7%s$qSID*l#:u$6I5ZGgc``3NY&E#8-U:%a?Bu$;X^:/abI@#f/1h1'eQ4(4b$c*'XW?#?CR<$9%ax-$Qeh(@P.1(00Swdn/hH2+&7;%#4vN'#jdS)qG-3'TCD)+8R/m&q858/3Pl7(^26'=Ucr(69#Z5&:WI)*iIHlLBMoH)$,Guuf#q,d:d7iL_38s$w?S8%/[iUN/o.$$)%x[-moGuu5/i?#L'(m&$p9I$mo=jLr]&&?Kq%@#]#A@#De`w$CqBFZ%N$LcjdrEK@0lf(dQJ%#+Sl##[*Zr#ZA)4#4f1$#FF.%#hd0'#dcGlL3rih)b]DD3?IE:.upw,*TLB(43$L:%r50i)jAqB#G+Fj1SBo8%_`7&4%CFA#pW;E4ml2T%O`PS7e^HQKWA`,BJTd)G*9fB85@g`W9qmH-<.OS9w`04LYUh?'cCM+5WU&_Kp?r?LWcYQ+642e6r19h(Or@@#Y<=;.9-x,vN0GO''m>554H&w/%2Puu1dqR#5.$&MMLpo8BwiX.R4r?#%Zkv6Z)YA#WmkxFY8W`[lK?JCT$f0:,,]R'JYv<'18i<H.^4u%%aYp%r+'M)@3LPC9t%5La+:B%fQ&%#X7'0%(<jk(g6(:)i?uD#S$]I*7PYS.x3vr-g5Wm$eBm;&qHRF4TMrB##_5g(W@<5&Kh.[#7)bfM>hO7Me?xS%#-YU%So$:81`T$5mS4'5`EjxF.+CJ)&tn*+<IK=%r$?,*LDh*%0F6Z$p.e[']RDZ@H1IlLE;J-)$i4',X=Er4A=+VdP[LYPI2<A+u2#,2'.Pd3lHuD#(1]5/%5K+*QQA#GFlP,*twO<%F]hv-iBuD#qd8x,@hR@#;EW($D'rE4Ku?)a+v6s$jrjx$9u$P)Bq3',9'CT.q_`p%:[Xw$Vmd=/SlD1LPfX;-xQu5&P@k2'fM1#$nPL$'p.SN10p?7&81KE-[+J/L1<Y<UQ5###3Ya.qR;UwTH6^f1BLgr65oI-*`ni?#@,<+3U4/+/uid8/X<0CS]5d8/+gB.*b,Qv$a&SF4H;*x'V2Q`,fhNt$el_V$FDxA(Y>tjLc9V2:-'Vg%Gsu5&fRJx$(9'_,htgfQtHo(TV&`pEe<+.)4vZL.,$=Z#lsNmL&kv:&.2i2'K-x<$ej+B&Ebf?$,v43)I;r63RiAT#%#ukLQ`$]-D,%hcNAP##[j6o#D%a5/[pB'#ME2;9)%_>$wil/)-h7e*H[sp.Vq'E#EK'nj&LdRA]eld3]L?Z,W5MG)>L+Z6`w[t1?1b:/OYDB#?t6^4+IGn&M<CH2)[_r&iuiw$NAYf*?,,uur?Ma3w-vn&QE>N'@%SN']xJ'+2r<D#WCjJNR.5%t_'<@&]67HDgkd<*I$]w#HB99%'dLQ/-:3e)%$UN'-w*Q':6Sh#5hO]#6>uu#8A6`a<G?`aRK`l8lQ%##m@ie$7DXI)G$5N'[KA8%G`#gLcI^I*3h;E4$jVD3Z,#d3NAQ#6C#ORUYEtQ)XIF<%n=+E*1S>$&L&b=&KX*t$P6[DEd1P_+Xh%[#Wh-c$K;<E*1q/30X&Ox%NI/3'5TKa<.E28&A0CH2YW9%kQa.F#(jMt8w&np%#E.60(`8p&Gnv`EJbA2'<B@iL^U%c$B=*T%G<^q%5ZV6MOX>:&-Bd',b=Gx%51k99F9`Q:Qa>=4,<Cn#<^U7#q]Q(#xPUV$L@[s$EwsHX]sv)4+gB.*-<Tv-5x>K)qIRW>w-Kw6gPwh2$X'H2]q.[#hDXj1378C#YR^k$HKRC#d+I8%Y[8q([h<X$u0;,),)d=414GB$U&?v$u8[@B9uU;$R,$5Jc58F%41]8%e*&G5B_39%RnEv']7Y;-Z.bL5QgX;Hmt#1/mVa]+e_>e6=x@Q/3iCv#TsEK#Cs]A$fs?G=X1l;-Z8:sH'/###fK#/LG262'Ij_c)R8N&#>Tg0'w3C(4kR2.N?IPS7NgAE+dpo7/u,u3Lxe9B##/g[u`o[U.0;`TVN,CM9<]*l=8/pu,q^EM018r%4i`Db3WVJD*6BOr$5ewLMT4^:/o<b]#Q(7]6=RH=04(XD#aBfX-%FT'JA[e5/Yu/qM9+?l7Y#V<-Ye'IVk_AW7$&5>#jxc<-LKn*.<LB@M#Rqh7rwAW7Y#44'IrYW-M5.F%GW'%#xVW@tsubcalqU<%d*el/O/5D<3-59.=R(f)5]B,Me3TF4qG,J*Zk[s$Fe75/:N.)*mg8x,/O@q.iE(E#iD9F.otr?#NjeqJfb[F469ZlJV5do/*ECq%f7LB%jU4gL_V-_u5beW$lbXQ'@6vR&bSkW6U-QV@c5qq%1j*.)-?Rf)5*J>#FV>C+EDh[#e1@`a>MA),ZJg#&dYmr%QHGN'M3pM'2_2n8@nvm8F#UT%o[i/)Gxm&Me^<1)S/[]-]'w<:[TbO))li$#%)5uuDt95AvD,W.xX;-mRdo;-W(FN.`ovs.Sx<g14qVa4c9OA#axJ+*jeTfL)u[;5G`TF*qd8x,RWTM'%e75/4Ob,2R)LB#K^Hk%1Cb9%2PSL(TRrs$e<,Zcdi)Y$r[Aw#U#N4+-Q5iTFSuY#j7od)V'HJ2&RCr&^JMo&'in8%NF-1)5dU?[lIE`u)]B:%k(tP$SU7W$14BL*Vw,q&:06U9J=)?#NP`;$A^?d)0HO>-@xWF3uO>c*X5vr%:YS?5XI;$#E->j0'_A`aX-]f1_Vp(<5R[,3>c,B?fifF4MK?I2q)`vHnw]G3QVCn'k(TF4h:=V/j:2mLOjs?#gmTD3;*YA#cE'>.Of&>%.,eQMF(9X)#Q5]ujjuN';RF`#a'jm/Iv2T%@MJ-)Ls[<&7/n@>w0np.sHaQ/&H4f*@&t**XV:Y--:@=-+rnW$kq*eW.sUP0Thi?#>1<5&&&Wm/bmpU%pPwt-nWHW%R55Yuk&17&WPGp+e9uM0r/5##[*Zr#F1Qn=Mils.O@i?#g/8fPkc8f3dE/<7AJ:r.27F,%*a[D*TmCSCkAsQ.vqGg);4Ha3_TIg)U78C#Tke]#nMp@u9njp%>b8Q&P<pm&M?pm&]tO-)lu<.)Mtvc*R>K[6CWp7/weOU%CV_W7/xaE44U=B,kNl/(LK#R&Gks5&SET6&HZBC+go&F*G>.21fv3V7<RxpA9KIL2-t339s4pr-Sf[+M,tJfLm`/%#o2IPDpBkKPJV*w$a%NT/l1f]4v+6f*x+7Z-]#:7LHft/MIskD<dEDH*V?(E#fii^omo#f*Y7vc*FC9N0,GcY#^5qu$]AXb*%Q,=-$Km1/U>[h(G/mank99U%Jx_Z#;M#<-BF:h2APsGZ<WE%$FpHd)C[^l:n?X49M['N(,p&UDrR$Y%Oljp%&kkp%M+IT%R_a;$=fDpR/^[`*s#_m/?jh7#pnA*#asIa-jTs?#^4K+*1j]iL,ei8.c%*9/ZktD#0[7x,*1ip.$s%&4(G-jF6UiX-2Vo6*ln@8%Na*<%$h'u$+N[8/jtu1%.bk$>eAr:%O]3t?^/%-)L^CK(SOVZuAcx<$SE==$flvv$CEG3'w$rN(c#$v$d8Uu$U6Df)TPwS%7Sv2T+a`?>0ebi$?a.3%c*Ba,7WbiC`/6Z$L'HZ%?ctcMl``g(KKcj'C[n8%ecE&+QlOe)&YF[5[QbT%+2iU%TBM^+?F0O1fm9Y$)TRV6R]I?pe>P:v=3sY#:cmx=9mr.CY-&;H*i+DN:E-)*JREK)w=XI)wi$i$@4vr-A:G<q79w)45Ulj1Nnpr6*o[w'lU'v5mna8.b+^C4ox>d3&?JIM633M2d;Qp%v+h.*R>1IXqYb*ETNYD4p@%b4>U^:/uiWI)?:0u(]hHuucq^DNQ>)W%/R(3(f0,4'Eow?$`U)W$.fUv#TNtx#@-G/(u6lu%$6Mf<VLlgL+F5gL*/ru$hfP=lQHGN'4>_e$8.0i#<L1hL[3/<$:61V%FN2w$k+3D#;[A2'[9Lk1LUkT%8oC<7#e5n&lF<T%@I7W$RpB>$8:*p%ZhH>#q7p^+2>l(5>>Wo&KxG>#kkjp%U*sZ#22TKM5YfRnZ>u`4$wiG<@EJb.aqWt$ge.u-*9,>>FjYca=p9n'Y+pu,4EZlAO%[oV(H;f<,@)'mq#iLju+M8Iohl8/ujb59SMl)4#,]]4I9C)&/N.)*T9@+4#&AA463_^=L+LB#TRoU/QIHu@l4dK)D`.S)bDVO'u=/T%r@6T.H9tX$./%60us`m1>;u98*@v$,x[BJ)/CLE<b*4t.^b/.*i02H*^%g;J'I*%,Sc5>#j*C2:6JAj#uw&r2*W92)o.v98'H-o/en*Q)5A,%,g`M3'#7US0cYm-*vweA#cpoMV<ggo/9/K;-VB=g$,4wK#,B%%#C,>>#26MG)<=_hLS,+Z6xck-$'C9u.Sb^;.OL@6/[60n&w2HlL^HW?#M5;Zu*EV?#MCi9.ZKx;mL(72L-PNh#=c[m/fXL7#$K6(#`&xY/1P'f)[/*E*Xs^5/=E6C#vL6Y@sE-Z$%uU5%>4vr-le.b%PMu<-?EY=$mkUC(#t+o/4$u9%=r(?#/g(T.4C8H2?pdY5sVtI=&9(;Ql6w*3=QBq'XN8k9,PG1)A-n,DDO`d*SQu/(q#1UgXnduu:g-o#Dv$8#?,KkL.,u)#swbI)[(Ls-STnj5wx2T/HcTF*XQpR/D&;9/[`JD*R4r?#R`>lLuG:u$rO8U)j,wD*X8M&=Clp58ei)'4x:MWH^E<EE-N^5L9rQO(n#HB=^.2M:WxqV$^023;@R*p%)u#(+F=&H%IAw'4jjPgHhVnH)9hdZ,FHZgLpR,L2dX,b78tt[&vba%$N)6b+Pt]M'mXgW&'/R8%jHZi(^RJD=Fl39)*Ik3T5:wx-dp]uG'uK^#AQ=8%dK+<-vDu%&?v:u$w.gg6<nVs-ax;9/A<3E4<TIg)qv@+4m^=?-0YDu$Hw*F+wOk.)G<n8%.4O-)nxrIL<VfX[fN&m&54[s$`;bYuCM/##pNqvAV0([-V`q921pr4'u(cY@R3^CMV@nM0oT5t$^<<h#YbEQMfX>;-C::tUH/5##7'd1%vfou,)Whr?IeK/)6*0<-kq(p$1=mg3-_]?M/*NS0*rp/))g.Z5i.i%,92ao0o6j'Ph6MRNHIf'9]8H]u0CtY/EPJ^HF4&q/8mKNMmoQ:v'n$p7gJ,/1&-&##sIR8%]?[Ku<p3M2[C[x64EHj0P4n8%K05N'gM:u$^$:v--twP''`uS.HXX/2H>69/IQ:a#v?$gLf^YHjmu%P'W17W.[RQT.ir;*,L)%1(c%%`,_-'6&'-O^,K9K7/tB=9%J$f@#ATv501o;*,vG5s.:d^F.xV<**jS%h(]?.E3j?[=-IPa'4+h1h(NZhG)7i^^+`ZS@#B8dT%MT+',b096&tpn&,a`AB+Al=.)BqEJiUDcm'mZ102SvK8/B-^Q&/kHeMLwQ,*h-[X-x1-<-5Lco.lP?(#t1T<9#j7d)Fr%eO3XkD#dMi-%Tr-W-9E/lB4Eu]u<-PY%`%,)NOHu#+r@[=-;Q4K2C_R=lNPbi($),##;j6o#LvgK-ELI6/5Hrc)Xl;g;dhk,21]R_#oe+D#<gj::KOhf)t4Ex'pr[1(:.E`ax$SD,Z.6>#dD24'<6cj'A-cJEGr,LENF?>##[u##Z<J)45Pk$%`._Y,*#?s.jFf_#BODZu/r@@##g0guCN#V%Jw6XM6=^h$5<GO%&>uu#l-f5/J0`$#pn.nLi(&],&r:=:hP))3tlI&4]Lp+M3aoA,xck-$t?&t-B3+.DwTW/2-mDThfV8f3=Ha.3<&/k;[Ob1B8iC;$0kIa5t@Sk$Hke8%om%p$tg`S$NC].*-8,##Z$W?#5.jY#Kmjp%<hV>#QVGt&B@j8%KE0Y$#6vfL*+`p.nRVYl]nKdk@-jf:3e&K2/Z,F<)/?v$$?[d&7Hf0E^3NZ#Z5qu$Kf4HP&4^QEli%d)CXKP:`VM(SA6#q.WWt&#l^s.beca2%*c7%-$>`:%@=.s$9[q^#[cJD*Jk=V/3@1B#8V1]twm5g1OxmD*;x(Z#_Di7)exSt98JdkCr8,CFIsU6&$#;Z#;T=?#Fak;.Oa82^4P3GsQan;%lqu'8?vIj+onZSJU)bs%3j5##veg>$RH-obe4mT8&n<^,L/e`*(UC>-stT%%^0R((S7l0/PRR),v$;/:[,p=-0N,f*5_GX-3,mF<DprB6bgb1'QG+m'eAtD+'Q::%2Q4f*HBHX-BSo34@tae$5@)$nJ6Y[$$4wK#Dh1$#WL@79$%t$Q0a*(GhX_C#%KCm4OCNl<]8RBoLGY##5k>1%#9W]+$B#,2DX,87%ro,3FHaB%''SN<fj'd%$De8/wS))3m#:u$t89o8wD?v$6FLB#@^r%,p]-6Mjf8S[td@E+XSu7/iq1D+=*MPKg9/m'Lg*T'.bJN-7c+a<3pT(,oOl/(NgAE+9lwGV9DD:89x0c3nl'S-KGg;-9Gg;-eJo/0ZaqR#r`U7#vP4W3[hi?#BKc8/b3NZ6#@n=7*J*+3j_&w6rF,G4a3FA#d]uD4Ces*O42?%-c@T>,Z&PA#WSnc3[t+.2g/$n&ZE]w#?O[W$eKp6&eNJ@#x=Fe)eT+T%]i@T&8<BoLDGNO'Q<4h:ST5j'iHb8R@;@T.5`u>#]=u;-fQa])r4KJ)p9(<-FFI8%6F3T%fasv#:5YY#xbLP/QYr.LYC18.E9QZ-OM>c4bkD,;KH1a4;B5P3/HS_%3ipquYHd70EfKB%x3a:8eU`A&Z']&6^JK+GL&S&G3*gsT;43<-6mmu5+&>uui>*L#@Oc##.Pj)#s6D,#n([0#)kKS.V*4T.2R(f)#C1.ViSje3ET3.3e/ob4p@i?#LYmG*PdkR%QiCH34tFA#3&lTU7UkD#.4SN9,teA,fKER%nGO<gGC'Y%V-Ba<rTF+55:x),H>0%,E7Ev##6,x#v*f1(iF`p%wbK/)FVN-)p)mn&(R+q&YmAK2dDsA+n5k-$tvrc<NqGb%A5Hn<1mMf<B`8C#,x'/)@ECE#<C<5&5v#A#c-49%`pL-)Aj*.);x34'htYLMR&'VMY7>OOa^_u$M'm=6'>cuu8a$o#>d_7#&Vs)#o$),#EK0#$Ynn8%[wwT%<PsD#S#wA4QMn;%?@i?#4_Dw$Zu/+*OV>c4Ct8i#F6C]$dC587:d8x,Tapi'*o&02is.T$DwoM'+CBF&NiN/2GValA6ZOY-f0,3'lH[=-m&*a*9TgJ)H[U^uku[[#Iw0F3j'@qNUH$>YU8`0(do`8&-(@Q'Ne@t-27it%XIhb$KwAm&uAB?-4s#f$Q$Z;)s==-)Ln,D-.dY1N[[$##EJ4;-/k4GVP(fc)k(x,Z&@VP%[R(f)iUdP/Z@i?#2<kxFJ59(O4]6C#E=?G#4V/##V'r0(RwJ/+&MRV%fve+>oflYu%Y<N%2hget4##L#Tsn%#rpB'#FkP]4cc``3mS,lLClUC,1.+FP2XCN(2)^g6-.u`'H;NG)RJ))3,5?m%DBqg1C+->#Jc.GV=Ik`uXS9$+;@t<-`?Pd&:q+Y[$j^`<=^.^uV+>uuh(#3Vp7od)w@gE[Q5YY#O*[0#Ke[%##i&$f6DOgnC.t'4q4&N0L59f35jic)BLR1M</:Z-AIX205HSF4%]v7/vi`oCTWej<C_39%nL5r$gD74'XeO-)/>OS7EmPY>C#;9/Xg;A+,cJ^DLT03(tv9H2']sJjvOI0;(vcERb`M7#jJ6(#=AgI*$3Tv-<)'J3%D+^4;2QA#%@3Q/%GYjLRb^C4/W8f3FB1C&E(RA#6^-LEg5i0E7k#Y-T(bf2;ltI)T%H1M<2nA4jIXp/1VXI)At*]#7FN5&jA2e/KDs80R*rJ)&k_O1F6^7/Q3QM(8/3%.9QkB,Y4+,MKwnT.BE',HTRH>#K6i$#:.+5rl`),)q%K+*B4r?#][_a4BA4gL^0Js$Q%V)4pnKCQ5#Mw'I(^-@,CP?#vx%?5gnt(AMBlj'+R8:;Xa8.$6%D?#+<+.)nE8NMHj6TM(XA`a)Xcg?GOiZ#pi_o<rfUm&;rcf:jURI#7SlY#AE_w-Z><UMfoBT;(7q#$9DH%bwLYS.KVou,2dLL.bdK#$E9+W-Y[x$lgYPH3g@AC#TP<^4ZisT%nx[]4sJ))38$Ai)f-W@#]*>F)>g>T%xD59%7s.?5B>Is?kx9DjC_39%a6We$3Y79%fkn9%>QT]=R9DC+t_Xd)s2Gp.NJXa$JT2Elpu24'/drtgoW+RF9A(>V<fs.L*Ah;-=.T'0.XPbuv]r%,@*%L-/_Gl$gahR#H$M$#*8E)#4_s]dKO^C4ZoI&=GwN^,V5MG)f1JK+m%Jd)a&SF4Lg3874W=d*g`Ku-99(04CK2q%O-d7&6xl#YSjY/(575+%Mt902ms=h#76Gu-7tY.<?1h7;7Icg(Nk`;$b?gq%DXfQOSrS)*6pN/2.=a$#$),##[*Zr#EB)4#UPUV$oNv)4qD%X//_$a$LSLs-ob*o9#]gJ)dQU,2S.+$(hK(l'tljp%j&)l'_wp?-OAIS@Bx,r%ZTXp%:vGg)a6WROXhrr$i*FK:m'(m9cG0b*NY;q.3Y7%-wdu2E,qZ,*%,6b*pol<-7+oi$X?Y70TMS-)[u5V'_njm&_uK-4dD24'eIS.Ep,97;`S39/^'IxO_o^It[CHg-6KMK('-j609HNK(Nug^%-cPw9qtf34qRZbH#?e8/2D<`&^Zv%+Oi_Q/MXI%#^3=&#$)nQ/q'(]$aLoU/)F)<%qg*H*vRkA#j2$x%*E(9LidN9MwI,W-#j1rB#xSfL5J<mLEO`X-&5n0#]c###;vY=H$OCW-'b.-#hxQ0#R9v3#=PC7#(hg:#j1PY#S?XA#>V&E#s2*c69%uL<MKs,>fB+g$mk@<-gTS>-O2w.%ng2i:@X5mqap'%Q=^&ZPQ[S>-IWS>-c59wPh+T-;#C5F[=.'/Q%0xx'$+x1qv,,<-a>QW-uKuV)u*Y>-f&N(&4$`;)$DsU<hdrJ6c9a:)D@q%l+<)KUUAS_UKIt/O5UtsR,b-]O:js.LDP[)8qmJr)#E[&#T:v&6wSJ_8S=gG3mE?J,OQ+R8[/*EGEK*c'/Bi;.,Tmk*mbM:8aKgPqomY18EPqSgX6]Y-0e6ns0xU<-#c%t7K2rC&eT.c74(P]uCh,d.*&N-))Laf1%,Y:v<:G>#_Sk&#IC3D<IMN/2T-kY$qT/<7p;Tv-xg;E4I@u)4PP,G4*??A4dM%#%JBha6<PWP&.47q.J6_m&(A.Q0-NA)=i.m<-/b`m$n6g['4Y;69`VDU2r,E:2JvOBde9nuu:m6o#>d_7#d8q'#PC,+#pkP]4#^jBJ78X)[]Es?#=J)Z[YB/[#hj49.*Ptu5OBL#-lIHh-T4cHZDE*jLNuU1.scP1MuHs?#to^O9rPld3+g^I*3mWI)Xg`_&3vIa<g/r[#CNa1)*>s'4h5rc)#x.$PJ_wS%(pKj&)HLH2D$0U%/S7[#&O<_,7gPA##6%<$CrsT%,nP#%>@.@#3v5T%q$YQ'c$Ku.tBFT%]NWv51*$,CHOph(QW^Q&bS<I)5>1b$)x2BO>@.<$46fT&S-'6&-v^TRVU>a,aAhW$l;IW$CuZDEm&hD3DR=,)HL-%,0WY]#WCtnMr,9x&elIfLF:-##2qh%%x7$##2DXI)C7.[#Hjq%4o'UfLJ2E.31MJU)'TID*,K5n%J]M-(D[@8%G^Lnu'CRW$KxF/(eg+p%gK'43mUeW$>1f/(i4RqLs)6/(OZ<9%dC`n'R]&Q&L<OLD,wWZ#A_r2Mow[n9/v6C#EQR12:GUv-cD6C#6`BH#;>Uv-Bhi&/,14D#OU*K)`]H0cp9X`<#$=v#nZ3#-HaZZ$PEX5&tpds&UH;w#W<P7J#0Aue44@<$nFZ5/[f5#-5f:v#/`Rw#_Q$)'>vi)3fXL7#Oww%#*^Q(#_[P+#d/NjNjWrB#:HF:.K)'J3ntqa*P#Wv-kLre;$%H,*2WR&46CF<%itn[#bj*.)h)S[V?NRw%$bNh#+sZmM0]g;-?sOs%6l>9'YOXlAZf0E#ZjJZ$r@7Z7t];/D#Tpxc>HIAGXQaJ2v<m%liGsB#NUHU7w:+.)Dt+6M$3oiLNtvu#8;-`aixC`arriu5M,1W-;nq?%9XXD#(l@W$S*61%eW]c;M0k#-o:gF4$C_p&Fn3Q/>kS@#7YHpi?d&a+P$$&4E'bX$2;,>u3')9.Rs(?#9.<T..oBB-E(/?&<LN(,wYQt.JXVv#%Csb%M0N0Mxi%6M[HXVR*J.&#%#pXuq/kr$ABq%4pL2A=Hx6V8&t/02gFU%6A($lL=,B.*0i4j+J.Dg*%P@<-e_94.VuH79F8^;.fb<u$HI;8.]AqB#55D:5S$]I*56=W[9?Ba<49t`<o/LH2Z8Z;%1$50.*?b.Nfd*30SF39%P1rV$4++A#pBo2LS#DO'ARDX:*d1Uo8RWp%SQpQ&8]uY#?pCKC>U_4.vt<K;=fG,*nmO324Q=u-gc``3?oV2(?ss%lbA+ok5GgJ)?;1W$HV.[ucmjp%F5PX7'T&'#(DluuUtr*%'jou,<@,87#$&##U`@Q-kp]C%Rg&ZPncWn'&5(/-VBZ^$wxDEM/_Dd%7F(lK>o*hW'F5gLDX:@MH46>#P.r<-%sc5&Yk*0:.#@g#]Z49%?f^p7[^kA#EUg_-WP46m_srv%9Kio-$nU3m::jMr*rJfLP$of$Q0dxXnAq%4@Of&Qce4f%Ln/<-[J1&&%tFA#u3q`$.`d5/[RUa4k=8C#GV3;?X0d&Qgs5/(Sl(<-Tx497CqW5&DW2B45kP31B[E5&J90q%,e]W$*NQn&VUpmATUDq7uX(C&2dO;-W^J#G3Eld2rS5x6D.Rs$PF.W$=LX;/3D;pLJaD0(pK]pTn)[p-%8AZROqoZ$m^af:pF>)4EuXGEZ/5<-J;Ej$p(q#Zx_QiT6up,M'.1P8+;3(pK5###-I#K1Y3=&#9i8*#rNi,#VIK^H7XlI)rC>Z,cCke)'Z1T/))TF4RSw;%M[lS/>8ckBoFv;%E;4a*B4/<-&Bon$;)b.3S^%n$G6D,3HWlj'VNhG3rjuN'g9e1MdHG-96#.T%)s5v&Rsp:%t'pa#YYsA+VvDm1br8m$a.wM'Ll1W$hXwW$Y'Y2'N2:9%>BAN0^NhG)p:4Q'tr-m0>koH)o*<I$_uOq#A0gm&+*1q%ZpIfhF0g2'8Js%MVLhm$wgj*%;L/W$S:3W$&,###qk&/L%V&)*h*.5/VIbK1?DXI)<b,l1o:gF4%*=dX[W-8b)^dT6]0H`u&)pG2^&a6&U9;$>v=-:8pHCE#1sCp.=KW)>vJZh#uCs-2-edk(RjvRM*I2XMdUAZ$uqR3Lf)q%4N8mv$+W&J3^FC,M&(YI)_C:s-Lp:9/_9%=(KpqD3#8o]4oO/K:s<iac4K'm('u'n':,@S^<bfM'AvelNrN&S'7F39%81eS%x]+c40i[4CYT,=$vS^PSIf?g'd3#$c6l:v#mL1-4HLAr8+WC_&ii(Z#d+Oe)h7^b*W1`;$%5YY#U`c=l8U&NL`<AJ12FkI*C5v[-upVa4stC.3_M%d)8K3jLfd@C#@Dn;%pbW;7Bl;d%OOf@#.TqM1hYdAu4;vN'w&,d5CtF40RxG$,T=aX.=6sOBX8R/(]10/)].wD*>6mN>6Y/p&X#,P9X5P;->8]H)s:G$,&>^r0E/TX-qh#v,$cj73&&>uug5wK#B[u##JXI%#3C]lJT_^/)X(wbYXTZ)4E2.?8`Z2^[3Ne20rUdB8.Uh(W7xg*%iu[capVN'#/V1vu<`fX#SO6,?U:vqX+A*/%]Y/fF-M1q>1aZ`6=gvJ1esgfQ]3]=Ep,97;:tp6*#ASY8b2vN'hu[fLh<2Dfqd%Y-ow)UD)Au^]Uv),M^#e##pvK'#Li8*#6b#L%wDcp.0Zc8/e[pcP03<b$1.Ha*RY9b*45XT%JBGq%$oD#lC_39%[`Rf<g#q7/p1blA/dT%FV5do/0mab*J+(6/DEhT7bG)*M>ZHN'f5u;->*.'53D7X14no7/*Qi3GgwS&,&,d`?0kNladD24'FSlk-YpJI$#+[0#/DW)#=E,+F%t(9/_.i?#T)7r<mr4c4'c^F*=k_VCZE'd%R>'?n$V@C#SQ0OO#wP3'O#U_6'V;q`UI@u-G$3d*(6^Q&fn3XU?65C&ITOIAVOUI6;H9;.tE49%R$@H)b6<v#%ocnAT+GZ,B_sl&xO3^-5De['$(lKj2ERr#%,[0#>bf/._V5lLC8L*#L*:PMxLGA#,39Z-XU@p76U5s.BK9W-v@wb%eB,hs=#FFNZt2.NkDK88k&1^#n-T_/k3Ls6CsV)33U-_#2iuYu.:9U%*X3I$qH<aE2?tM(9<^;-OmL5/d$-32qof$?$Tw,XZ,sa4>k49%XZh-6Q?ZhEkVL$'RSHT%&I*3Ld[sY.0tKT%:[jfLG`):8OPk.)QY(6VRO?>#C[u##;v8kLM+M#$S,m]#mD&2B<^bA#`IR'&QpTv-1]WF3b1&i$`Ut.LFNgDP?NtQ/:ZRo7oCs20#e%[uuf$e2a@f9CZ;Z;%=1EO#Ng4',#o;Z7W-A@#&150LYVHU7M696&$lj)##r^^#9JQ%bt36kOdaO`<T-ip@flgJ)4DNH;O)uI#6XXD#*Ptu588ne/h>.H)`5qB#BVYq)7jE.3MF^(/_V0T7QuD6h4Xnm/?Cx/(=@Y]uC_./2n8H01<BPm&9x?8%6*O)<Z7QWIsHeH)Dqws$f/fv$(dl5&#oHJVVrCr&V(xs$er)6/KkEp%:]uY#>:%<$K<f>?X3n0#]:LcD[1dg)Qw[rHb$M9i+;Ls-ZCu)4$,JA47T7)*sKqA#`=kN.Ff@C#%2-W-do&tqWEW@,1GWEedc``31Kmd2[00u$Q-Sw#j^LG)+=RP/mg6b@%L8[#qQpE@i?(E#'csk'Wvk.H$Mr[#tcme29r:ING4tu5;T@]csLN2Kh.4I)ut>C+V99U%N>h7'`-a6/:wx2'])CSIQJ%p&7R&m&GlGW-<6O7<#KeA#3>k>$J@8rLr6=xbeakT%N.iK(^F:Mqsf9s*8E24'-=P>#6SG>#_.`V$dQF=$U1mV$<4Yc-)O+CJ#,8f?Neq(#IV4;-]KiV-BT=8%8^gx=ce&DW..BPAWq[U/KHuD#oAic)nX65/HTGg1&'Nb$JBRIM51#,M4xke)1%I=7[o9HN/CYcM?-_M's2GG2^2B.*QEk7/x3vr-`(v4SasDE4g48C#?;gF4lpFp.baGj'd6f=1_^ft-;va.3<r^l8:O.K:ns3',n+=rnYHgM'B:V?#MnWT%S-cm'.#A;6B_RW$[FQP/c?4,2F'bp%fx7X%NZ9^#C[3T%H;6j:<LR>#;Q.[#9OXe%7^^b%,uIT%@IPd28o$v$@Se*3eJY;$Lt<9%`a27*13269(f>C+V%lWMteB(Ms;eo//_UZ%=USM'dKbG2E#At6t*93',&s-aBKTO0>4r;$NMK>#Lfo;Mm5Cq%7Z2uLpv[DEdO=,M6:Ev#b#&[>TXlU&:=E5&),m+%*?V0(r2Px#_J4t&M?;qMgHYJ(@RlA#^Z<F.2k)YPJu]&#2ZC4D<Ux(#Asgo.O29f3H7Gm':D-Q)F%V%6qd6.MJ17%-ROr_,b^4g$l%ws.e1[s$CY@C#`I_hPmNv+DRR39%kTEY-.wYIF:Hv[HM/2$>@,:#&Gr;q%,,%T%D4#NBP/e%+_p='&WWT6&h`75')j1pL9]>#uNFw8%h*7],]gpw'p[/r%+<4]%%jwE7)<q5&XWlmur5'U%YjuN'F2w`aa+JfL'w$aNBBe##P-4&#v2h'#;iFJ(AGXI)n.f`*b3Xs-Uvn]OhJ6H3J]d8/f:]lJtB5s.dW^;.9f@C#-Q?g1Huc3)aYAS'L9Bq%[?]_OSJEYP95K-)]w*W-lY^g*$Ca;$38Fp%5Vc>#Q8+D'Hk*R<vcjE*LA4Im(w<>#1rJU)-Pr),(P=l$7[(iL1EA<$J/A32vq^@%JB#,2#=FV?Ci^a*w[[9@P9YD4rnm;-Mc>W-V7%'n,BF:.DYvP/jAqB#b$g:/6qj8.*175/;7s5/q3vN',GRQMT[HLM[19VMAhYhL2FDX-M<$hc@=E<'be#nA/4:)lN*wU01k:P'Jhq.)IPu<Qr0WPKinbP9'#-v?Cv&vHX2YD4`lH#6LW@_8oK#F+UhDm5n:Sl3pI.*/>pT/)=,Vm&#.m+D<&Wg;#$&##N,3V9B>6X$On/H*T)PT8d2Z;%^:w;-kF'%%vo/+*5i(7sQ$a8.Q`m),i99YcqxO-(MHkQ/_71[gl<Pj'<x14'QXq(E-F3t_qX`e$V0(]NZvS@#/c`?#_[iX-hKqMr'>*s%BLmTi.A,_+W@,3'Kd2UMj]GOMv0-C+18,S.#]in%4=('#$p=:vMn$vTpAT%#%pm(#L8=c4RkY)4wnUNts4wS/I>WD#KU%],uR/K%o]qSg;OLp7698N0e-ji0,ue;%OXM_VlDuu#ai6A*8ZFQ1rSg^+.bq.)>A@I2C_39%'+W:M=>#L#H+VtQ57%@#>RkdV,apD#*]E`WMt'Y.Ci<`-a:.0)MpLN''Zk-$x15C+#l''d#(se._,_'#rJ7'&`>S,MZS/[##ZWI)'M>s-k]Te*lfu8.+:RP/$kpJ1Vq'E#+/rv-`Ld5/A*Gb%oBFA#nY?C#hfn2.1ChhL.GOn-eKEe-LS<+3_4I,*A[7`%sVFe-FJ8X1ZXfC#pnSh#^A7d2jpsV$_7l;-NL0&v)Lf&G9-xmsfR`INtWNq&bTKq%DhwW$:/bjLat(n'G0T6&P)`0(V`>k,Ox+@BlI`e$kAq8%CURW$9EKW7eR@].<K)Y.=,0=Z:5pF-xc(-%@`/E#e(U'#BVs)#v<_F*rcA7.B5^e*pOSW-muH['+W8f32'OS;#'i#?4^FJ*J29f3B4vr-iL0+*B]SA$>T?)*917W$H>:W$cI.W$[)KFEr-NPC%O(?%Mac:/)XCK2>Obr/x?mu%aVl8%ud?.MjlKNgdD24'^kY>#EB0Y$fP)Q/m<Yp%o`(c%&ZE9/R];9%93dr/E7i;-t@jf%t)p(<c@iQaLjTv-68wjDCxdX$e:el&U$Js-KqL)Ni@GA#@>X6MiG8f3-5%N0D.Y)4mN5/(wVLhLxl8W$iv./hUx.<?Z8Z;%qmj;$5]]i(iZSv%+74i$S*sZu+)Uu$c8$3'/hgK(5_v?LP)S=)@k5I6k5qp%9dI-d:W2]$:=wS%Bli$'UaYp%.Za5&$SFi(.S[GVV/%-)G-AJQNne+%;1,/LEvTP&Av[xOTfh.UE6*##6Z9q`p3YD#.U4x#+2pb4C7r?#s@Z&3&,]]4$4D.3(.75/-d%H)w+9TTmu%H)[VW/2U=As?.03Z6V=PjLpid8/#&AA4'(^j4Xb6lL*dfF46N.)*GI3n%RKEe-LIcI)_4I,*LHtJ)N2(@-g/9p8d$jF5n(&H)hCXI)2Wgf1`t-eQ=29f3uchU8EG1a4GoP0P8J[&4HjE.3((%],3GpY&Xe39%-T0TRLF`;$WvgU%6WWC$58HA#]I%OZv(*k'kp0U%&[r%,YK>N'vtB/3*a#t-:_Wa*m#;N0M,>)<f?<w,i'HAO+DQ$,&bA30.bWX*5D?D,:^V<%m6]p%1-p=>H$5N'MQc3'Q;Ek'c2M_#LXn<$7]1Z#3dHV%)BCq%7Anr%pAU6&Q2%L(VX:d-*#?mqo='[8fl^$-QWIb4WshG)`.BJ)@,&'.&cPc*8>Z^42>ZV$9DH%b'_A`aMu08.@'[i95Z&##[']s-uHvc*->N^=LJQv$IWOI>I*8/l#>,G4aWgf1CBuD#2saI)h@F,MbtHg),T[Uhcl*&+o,hv5e%a:/9>LW7.M34';324'bv3V7c*s;$OJfxOX_k>-PeTq)(uM.33_#F#cUKj(x'D/:cFS/L*4;/:.ikA#eJ1e4h[tI/#nE<',150Li#QK+s*&@#P,2BQ*euP9Tel3+deu0,;2=7's'amL?@Cb*h;@<$w.@W$xBf8%WN^%'YWf'd1m+L#U#x%#$%(,)MD,c4_v1t%0+Ap.h?7f3845t]Pu;9/*/P/C6U)A-XqE<8$Xu#%rF)1D.xVm/3iCv#r_jo9F$,/aU1wS%xMTW$`1<88i4FD#WYL;$K$/a%7VlY#Qq):/2YuY#NY7):CKE;R15da4E5P/_NP2'#&2P:vfK#/LOuIG)YYl%=i_m,3n;MG)4Le;-9++_0$IuD#,*8f3A[7e*EuNdD:j?#6w.G@n_/E.3Fm'^d$V@C#>G*T%cJ))3_ZD.3ewIr.j-D[,5Ydr.x6Vd*vp$W$[Wfs$t$Wm/=CIW$$)=cOH9tX$N>uT8YDhT7K1IH+$q8v-xJBv#38k9/$)dxk&=*p+0](Z#fM4[$ttMm/?Les$dIm<G5%.m0D..W-,(XLsgW&%#^Re+O'7]8@G6?thxsRF4/Y<9/hp?d)k5;,)sA&9/>]v7/2lpK;A7O%$okb:&t-iiS5(q7/3TE$v%tV%,blcM9q]I1(Sd>aPMgH##IZhR#+ZL7#v'8+/fY$0#1]R<]CAP^,[YVO'V:Ls-u,5)<`nE#-j,E2<Y7)4FRYIq%D7;?#XoNe)+3I12_Q^U%WD<W/axA.&WTsAFb`dl9?8Eq01].mMwrJfL42IN'pEr4'Hcnw7*48<$0FIWAj4`B++Qb;$*DokUIt+v-)`^l8R@_'#`ano.05r%4Tp<J:)2=Z%PCs8.4g/+**^Z/1s<RF4iFo$$:q&s$*Oxf$LSQF%].RF%:iVLDfUHh,t2#cEv8t(5:[k6&k>l(5mS4'5XVwH)=08O9-RZd3Br'`$`lo.)d<Awu$]v7/@W9I$siIfL/,NU/iweo'2kLf<i(hT&oMDO'6=B02*gE9/lQgo/28R?$g@`/)rcVX(t@$##4O/2'?VXo[s_131.3ZlA2Z;'f,Bic)=ljj1FQ:a#niCgC32Zg);Mx_4C>lb$K:uD4v7H)4:)u'%:;g+4+vL&MMT6N'Toje)51t`#sc``3W*Q8/5U8J3vuUC,(gTv-F1DYPo_w,?LZpY#GL/@-?RTT%qp&m(RXwW$^;&^+3Ox`*(#s#5/q5V%<F.<$cfIL(6ou>#tRq0,=r(D5G6Q3''O;78fiBK#)P,5247as-p8HQ/sSRl'[mdD*%kUj0.KF=-uFOM(S9#T%RvuR&p[,(+*9#A#<eWT%rJpFE`jP/EWO+=HlqC/#56j%$326`an1D`aTk%/1^'%##=pTv-$3^c;.0xb45IL,3`69u$]4bF3cvrI3@$,uHnoL*494#i(@ogh(ZL389dl$9.ljCK(*Kcq%SZw-)CGA*49>7>#.Y`vu.UHU7$j-$.Qi1e1XbP'4k&vN'KCk>-2C#VVr=u9'W_`?#iWaWAWU02BJqa8'*4?M98<.J3NVd8/9&^F*+2pb4bf)T/KB4J*JTDJ)>mj;%V8x/M>FB(4]1&9.vB17JZn+MBPt*9%QguN'M4n8%f,4+Nutu3%EhwS%Q3ZLgJ7Bv-cJC27PaFW6>+bw$7Hs%,Ekv&OQ*kp%H@Z5Lb`w4$V+ofL[f9v/q9R90<I,2('.mw/PgXV-_QJl<,G(v#rg@Q-0=>T5w=N)#&%(,)DtJs$]::8.@S7C#W=[x6imQGe,%x[-P3FA#kR1oK91Hv$UcOO%DII>##cnw#%ieRn4]c>#>OnS%^A^ppl_)G+*xq%,kwg$5MP.[-/;+.)Qc,##X5&:-G%lgL4ovY#xk9'+WC'6AD8oB4RA>MCZdIH3<Y_.G/<UX'u(Tu.Z-d(NtgH>#BVr,#KaX.#C%r_,ed0Q/`M.)*vkh8.c6AW-=[@3kJUCp@jRP8/2nAp.I>WD#Zef=fY+-e'NaQI<1nP,*:C^j'<$ol%UdYn&B9a`+;R3N0a45_+9nL0(V'&nLl8$n&=:Mt-T^ihLastT%ZAc2(MpAf-%5v10Jg4',u3vN')h`O%&wr#POKihLl/$3'ow3B-OZN$PsjVK(Cpf+.DI&O=3b('>L.i;-A*l<%I#D`aSRt1B8d&##486J*P3FA#j::8.r_7H+nVfF4b4^d)frYq7A4'etkgj?#cMAF4+87<.#qtu'fe^-Ms>v-0UQ^q%;&68/>w+0.X*Q/CF0&9AZ#Zj'A&ev.iwBh2o`%P'vl*#,#,q`jD8*1%+u*L>%:`s%(O-*NOEVM82NL2:SbRf$s92hL)Z4e)GvS>#GXZM9VwW3L42:D<xf;]X5VGi^'8n[$7N>g:rW/+,qeWLDA$DT/lNXA#9MIx731T;.B<@t?nQ^I=<pfP+wOk.)%abI)Sv$h()J&(4-,3'49W0j(FMZK)p,Uq%Td(0(Ig]5'SNfY-%s_$'l7=Ji%5SgDQHGN'Kx7_-%SK^$GMf>L['a=L1/2g)Wke/)'PT3O]=M$#=Pe&,&0A>#*ok&#tY6A4/(1B#mwFcM01L^#)=PuY1:h#$7pM+r2C-?$0U)/:3LHZ$P)8S[4Udv$@IiV$8$&9&s4mrH9-AT&f>Nig>Zt2(LpC,)?d9N(_gTD3@mTj(WZ*&F?p,g)C)7;[@#H,*jo)Tf'5>>#_YE-ZRAl-$.(1B#QAl%=<UL^#x4`+V1:h#$k%Ko[2C-?$kuMG)3LHZ$(0DMB4Udv$(G^+i8$&9&D62#,9-AT&L'5DW>Zt2(7E1Po?d9N(W_dP/@mTj(<%O>5C2Qg))nCDN@#H,*r%Dcb+/G]FcgXoIT1PcDH]4GDcM8;-YqTiB+D-F%'QNk+G&RX(Wrv7IQe`uGBB2)F>NE)#k^T%J$'4RDCKlmBxlndFh:3s78M`iFKU&##1[l>-/q8O=#%?b74bf'&f3/U;Q>qHH]&m639ai?-12kaGbZr`=@'`qLt`b,NfCFE-uEa#0-K6(#/9q'#++M%/:?Rh2)EOe-*/;Tbra0bIt#$CJXYnx4<=:p/t;Qo/T0f-#_/:/#^4%I-.<C[-GFst_xI$##>0rk11(4A-b]q]&H3iVC7;ZhFrGlfM%;ts7IAW5_^[-lLdj1e$^Lco7]AlJauKxR98N1U1LgOs-c/RqLJLG&#DTGs-/RWjLRLG&#$'6-.8#krL%mFrLn9v.#ZZO.#0]AN-D[AN-6oSN-cdF?-Rk'W.Hgb.#SqX?-QY`=-]eF?-TLx>-G,_j%cv-PD0:rVC@rLG-=C=GH>_V.G.gcdG*M#hF5xLVC2]HKF6-giF)QtnDHGKfLj.lrL/lFrL+>4)#K)B;-?</F-(v^A8i^<j1v.8R*bsTt1R3//G/C%121%fFHbFOg$FEwgF9T6E5T%co7X'$EP4%co7%C+KN5NV>8&5=)UG/5##vO'#vGgdIM4i#W-J&)=(o24##);P>#,Gc>#0Su>#4`1?#8lC?#<xU?#@.i?#D:%@#HF7@#LRI@#P_[@#Tkn@#Xw*A#]-=A#a9OA#eEbA#iQtA#m^0B#qjBB#uvTB##-hB#'9$C#+E6C#/QHC#3^ZC#7jmC#;v)D#?,<D#C8ND#GDaD#KPsD#O]/E#SiAE#WuSE#[+gE#`7#F#dC5F#hOGF#l[YF#phlF#tt(G#x*;G#1#M$#w'`?#(=VG#,IiG#0U%H#4b7H#8nIH#<$]H#@0oH#D<+I#HH=I#LTOI#PabI#TmtI#X#1J#]/CJ#a;UJ#eGhJ#iS$K#m`6K#qlHK#uxZK##/nK#';*L#+G<L#/SNL#3`aL#7lsL#;x/M#?.BM#C:TM#GFgM#KR#N#O_5N#SkGN#WwYN#[-mN#`9)O#dE;O#hQMO#l^`O#pjrO#tv.P#x,AP#&9SP#*EfP#.QxP#2^4Q#6jFQ#:vXQ#>,lQ#B8(R#FD:R#JPLR#N]_R#RiqR#Vu-S#Z+@S#_7RS#cCeS#gOwS#k[3T#ohET#stWT#oPtA##1tT#'=0U#+IBU#/UTU#3bgU#7n#V#;$6V#?0HV#C<ZV#GHmV#KT)W#Oa;W#SmMW#W#aW#[/sW#`;/X#dGAX#hSSX#l`fX#plxX#tx4Y#x.GY#'>YY#*GlY#.S(Z#2`:Z#6lLZ#:x_Z#>.rZ#B:.[#FF@[#JRR[#N_e[#Rkw[#Vw3]#Z-F]#_9X]#cEk]#gQ'^#k^9^#ojK^#sv^^#w,q^#,k/i#'?6_#+KH_#/WZ_#3dm_#7p)`#;&<`#:kj1#,2N`#C>a`#GJs`#KV/a#OcAa#SoSa#W%ga#[1#b#`=5b#dIGb#hUYb#lblb#pn(c#t$;c#x0Mc#&=`c#*Irc#.U.d#2b@d#6nRd#:$fd#>0xd#B<4e#FHFe#JTXe#Nake#Rm'f#V#:f#Z/Lf#_;_f#a5:/#<xAi#gS-g#k`?g#olQg#sxdg#w.wg#%;3h#)GEh#ZgLZ#/Yah#3fsh#7r/i#;(Bi#?4Ti#C@gi#GL#j#KX5j#OeGj#SqYj#W'mj#[3)k#`?;k#dKMk#hW`k#ldrk#pp.l#t&Al#x2Sl#&?fl#*Kxl#.W4m#2dFm#6pXm#:&lm#>2(n#B>:n#FJLn#JV_n#Ncqn#Ro-o#V%@o#Z1Ro#_=eo#cIwo#gU3p#kbEp#onWp#s$kp#w0'q#%=9q#)IKq#-U^q#1bpq#5n,r#9$?r#=0Qr#A<dr#EHvr#IT2s#MaDs#QmVs#U#js#Y/&t#^;8t#bGJt#fS]t#j`ot#nl+u#rx=u#v.Pu#$;cu#)Juu#,S1v#0`Cv#4lUv#8xhv#<.%w#@:7w#DFIw#HR[w#L_nw#Pk*x#Tw<x#X-Ox#]9bx#aEtx#eQ0#$i^B#$mjT#$qvg#$u,$$$#96$$'EH$$+QZ$$/^m$$3j)%$7v;%$;,N%$?8a%$CDs%$GP/&$K]A&$OiS&$Suf&$W+#'$[75'$$@U3$bIP'$fUc'$jbu'$nn1($o_G+#b+M($x6`($&Cr($*O.)$.[@)$2hR)$6te)$:*x)$>64*$BBF*$FNX*$JZk*$Ng'+$Rs9+$V)L+$Z5_+$_Aq+$cM-,$gY?,$kfQ,$ord,$s(w,$w43-$%AE-$)MW-$-Yj-$1f&.$5r8.$9(K.$=4^.$A@p.$EL,/$IX>/$MeP/$Qqc/$U'v/$Y320$^?D0$bKV0$fWi0$jd%1$np71$r&J1$v2]1$$?o1$(K+2$,W=2$0dO2$4pb2$8&u2$<213$@>C3$DJU3$HVh3$Lc$4$Po64$T%I4$X1[4$]=n4$aI*5$eU<5$ibN5$mna5$q$t5$u006$#=B6$'IT6$+Ug6$/b#7$3n57$7$H7$;0Z7$?<m7$CH)8$GT;8$KaM8$Om`8$S#s8$W//9$[;A9$`GS9$dSf9$h`x9$ll4:$pxF:$t.Y:$x:l:$&G(;$+V:;$.`L;$2l_;$6xq;$:..<$>:@<$BFR<$FRe<$J_w<$Nk3=$RwE=$V-X=$Z9k=$_E'>$cQ9>$g^K>$kj^>$ovp>$s,-?$w8??$%EQ?$)Qd?$-^v?$1j2@$5vD@$9,W@$=8j@$AD&A$EP8A$I]JA$Mi]A$QuoA$U+,B$Ui&*#L?GB$[%B*#.OcB$f[uB$jh1C$ntCC$r*VC$v6iC$$C%D$(O7D$,[ID$0h[D$4tnD$8*+E$<6=E$@BOE$DNbE$HZtE$Lg0F$PsBF$T)UF$X5hF$]A$G$aM6G$eYHG$ifZG$mrmG$q(*H$u4<H$#ANH$'MaH$+YsH$/f/I$3rAI$7(TI$;4gI$?@#J$CL5J$GXGJ$KeYJ$OqlJ$S')K$W3;K$[?MK$`K`K$dWrK$hd.L$lp@L$p&SL$t2fL$x>xL$&K4M$*WFM$.dXM$2pkM$6&(N$:2:N$>>LN$BJ_N$FVqN$Jc-O$No?O$R%RO$V1eO$Z=wO$_I3P$cUEP$gbWP$knjP$o$'Q$s09Q$w<KQ$%I^Q$)UpQ$6^wH'wo(*H=VT=B75?LFu<tbHjBO'%%QcdG])cGD]eDAHqRA>B-X0,Hf/#gCoD6`%D?;eEo&8UC_4CC%JmMhDtv/jBksaNEt*$1F7vXdMwBP'G/S/#'Auk,23r*cH*%AiFJGRV1fKk'%+^,LFWQsiBgvXGDkQFb$q2JuBuwRiFUaf/C:J6lE9<j[$xVpgFxrBVCoF/vGwd0_%HaO_.=CRFHPP-X.jW76D&R9[1%,QhFufMA&@xnbH+WAb@4sLC&sBn<:3vh_&9`q(%/j#hFVK&NB]S3F%vU=>Bj[j-$#daMBvA$`%MJF+Fh/(c$3/?LFcNM<Bus.>Bl-vLFoG9)4d,1dD$6'oDl=UVCP?$LDm&4RD1nU_&88/:C73SgL;?*LF3g@qC3qCC&+>pKF%j`]&Gge]GW;T5'EEv,E?GqoD5K8,M4S0^FIw1qL2e.dDK1#H2m4/:CgG(dDjH7UCmU,-G2Tgc.cdW2Baj-]-a=)_S(p[9C,7,wGE;@V1agaNE(-+;Cl[(*HM/Z<-Qc[F3foM=BtDo=BvZ+F$@lV.GsQ7fGV29p&jJ8%'.A0%'$ST3Emx7#'v@I'IWw;be9;7%'N@VU&>=4,H:%VeGe8Zw&G&K1O0TnoDBmO4+^Z,mB_0:<.)xbVCgtk6<dYBT&&p>hF_.D;&1+S+Hu^nmDo^WMB_p&3BDOkCI3g@qC2nCC&D7$W%J/kYH^ekV.2%jMFqVO%6gaoJC1NKKFc(vgF.dFVC,)2LCxHM=B%gpoDQtd@$$8rEHZ8d<B^MBnDdNSJC8$JgLBaL$HxVKSD.W4@6*e2=Bv#fUCgoM=BgsojBpYpKF3;RV1l]?)%JB]'.408gL3ulUC$,I&Fk/xUCRa6H+1>5/Gx6Z,Mvd-ZG/8uVC(7,wG1c`.G:vCU1$i3GHlq>lEki`]&XdNN1,gpKF%ZUqLCi(RB<h]3FE+2eG4CDVC'6l+$rS6H$&G`*Hr[JkF6q]vG&-7u1kp*rC)nIbHtv@>B%$/gLXd.SD3C4/GpE;9ChOT0Fw.<#G8m6t_dYpO14TJ>BwFxVH&3JuBpLrdGv:7FH)s[5C*Bx+HWAV9Cp3vlE/Y7fGf,fTC/BfqCq]CEH.aRqL-ZP'G4ieFH>D+7DDiZBO)XcUC@]HBO9>5/GKr%ktA?K&ZYCUp$#lw92H@BY(Db`u(c$vIP)I)[%uqGkEa9b'%6mpKFi@S;H,l.+HfL^kE#W)&&r2JUCmS(*H2h#X$^Qf6B)ooVH7ln+Hlq>LFdY#kErd=b$VH2R37OnaHorugF1ia#Gx42eGx.v-GsH%'I?T6H+f6_MBrrQD%61=GHcownM;2=lE5BffG'8iEH8=4cHrb=WH#g1eG-)[MCW2`p.]NFb$nmNnDsKbfGr/Z@&)HxUC@]umDj&^jB&MiEHF$kCI)eCC&[:b4N,XcUC9#YdM943f1jh>lE=lI+H'$8fG(%9I$Zs[;%QfpZHp+mKF0#vhF*[rfL3VIc$n_(g%%NaMB%gZD%/ZXVCk5Q`%0pldGndM=Bn$)*Hs]HaE&>.FHu2jXB#xOVC?rP:C>hI:.8cR+H.OpNC(L$pD%T(*HrmqpL;=6jBpQ.UC/Jh0,C_7FH[ds2Bx7(51gWiTCaV`9Cx+s]&1iWnLZFPUCogH=.lY(HDIw%Q8BP0H4kgd3Bv#fUCG1qYHOsFp7Rk8Y(i$<m'k%lYH$N*Y.2%jMFWs@/Mi$VdM`%7A-2xcW-Yc6.-X;k<%w(HPE(Nq(%:9e7MvZ>>Bmlt?Hi+/YBi&$@&C=oFH,Kcw9)7bw969x.G$ExUCiO'HOnc5vGa9Lw-.J[rL<)^&$f^BC%jmnUCbB9_%%Q4ZBv,+;CfPM=B.YcQDhg[UChN9_%25v1Ft5kjE_ue:Cj+CVCQ1=W1lu%Y'Q0<w8_hI5B3llw.m?ViFD:j*.XWjdGjseQD$C6lEkpbF$&p>hF/'/?&FsTcH4ln+H(Av-G4nTcHJ*7B4cr.>B%s%#'SavAJ=ZR'Gf<iTC22%7MtENhF;8H'O&><j$$gIZR&^AhC<v1U14VqoD-)$pDjCTEnS]@rL0FI8)Ei1Q88dgJ)]D=^G&>.FHMt`X-(8hi5=$kCIDm9wg1(EA&=V+^4=CRFHp3vlE7(F$Jeu5kE2l[+H@<$LDQGKvH1Bx+HntMW-ph6q0cDI^$LRfBJD;34N;jg#G2IPC&.UHSDcf3$N/F?jB'*s=B_D6R8R`SU)2InERE7BY(=wbr(v48nj6n*bHP>O$HmMv@&<oVMF<G76/ok>lE=N<SM%,HZG)k%UC0R)W%$VL9MX`LcH6?E:)Xl@rLsonq.dL^kEnw8I$+'bm'B=4GH@T@&GP=i3O?iNx';e+;(C<2)FelL<&7mj^O;A5/GB_[6//ToUC<b_QMjWPLN;>5/GuV$N0Td5/G+nIbH@WESM1X2gCo2kjEjk8I$CZTcHsX%iFj^a2Bv#XnDe3WMBdmi#.)bcUCmG#0CmQSvI/x%9In29kEe^nmDu+$oDpQW9r8Kx.GUOPBoF9OGH#TVt'#KOp72_i8&8Q<e?G=hoD15D-D&s$bH?qh>5a5Q`%r/X7DrH7UCg3[^Imn#pDwY>LFFqR3Ox5]*$q;$H$og`TCCM8s6v%CVC%d'kEPEM<BpY=>B(>J;HiTB_%js@>BFK&&8p:O'G^)PgC6d1U16W+;C57ip.uviTC-t:C&NHkCI0cDiFJ5koM50w0FKk;p&F7xKuE[f5B+dYhFMGKvHqJ5hF,p?mB4L:qLY3,UC>OpQWLdsp'3,0iFo&Z[&v)4VCa=GrL4K%C%21=GH0A3E%+@16M9(ZvG$2^Z.I<$LDWqef$3CRFH[@cp7wU?T.gnY1Fhk3bH+g>lE3/$&JhR>LF-8vlEoVUG$2&C8DxZeBIR#Lw/oIfqC[ZM<B^LViLqC?NBOTs[8(xM[$4,)*HvBB$J7e&eGmQ0eQWT3$pYWjdG,j;='++4GHv7w#J+aNNEYhd90u2adGg'=h3$6IoDZMJeEk,$@&+0o6D<Q7bF+T'ENqdwC%^,HmL)gfaHx($kE%k`9C:eQ'G48vLFnAQ[&%3tNEj^Y%0lDZ%&$i3GHX3>k-3ku'&QURfGF$c3C'H(G$.#v-G'xOVCFIMVC(MiEH7M@rLIb#p13BffG:SeV15MeBI'W:qLeU^TCuw4sH5C4,HihcdGq]kUC6onfGj<2'o?u08Dl^rTC:K7`&BqhjEVZdt12Rn;-nUH.N3tLdMUt:eML%lC.q>v<'Zg`_&uf8/PrE%(%61OGH5mOdM-YcUC=</gL0>iVC9%>na[7_8&NPB?H(5M*HR5`9Co<>P4uOAvG)3]>BmZD<B9A2eGP65bHD`HFN-ERSD/:)N1lo`Nk;kn+H[j$KDgY`t'rhRL,<V3x'81D.G6f3'FvxlU:fl2PC4MRU17Fo+H+]a^FdEDtBIwAeG1SJY'L2kYHUn1e2*FqoDC.=W10mXVChquhFwK(O=9AKKF7vN$HegeUC*t3cH<6[i$<SA>BLY6'Of/OJ-@R`9.esT$&AEAt%kj[:C@DJuB&[u'&4`,-Gb=<'dxmluBmv,bRGl=HM6*%oD+-+;Cbi4#Hf?:@-o6*3&LcWoM8'2VCOnIe#g(A-;5`R&G1ffY'HHD)F?6@]'<+$1Fg]BD4c?DtBoC;LF:U=GH.AR&F=&S'G2Hf,M,TeoDpA:,$/erS&YDd20=CRFHw6`aHbr%?ew7mvGS)b4NPs4-;c0xPB0AZBO:&FPEmYuGD*c.FH@#Hn8*SO6B,vssB(rw+H$p$rL9rd3B+dYhFb5Jt9:h5gDX`7-;&t)u/p^$NBx>^kErfl4B<`r*H2gkVCFe/F%?M9oDD&O$H?#YVC3l`5B'g^oDTGX</fXi69BraN1*jXVC3dFVCkTHt.Rvc<BFG6thQsA9&N.+W1NZerL11/HDv1D*Hia[UCR:.b%;S4VCdp79C':.hYF<ngF=_C%'(JcdGVDre$_g^20&S(U1^HR6Dp<Gb%Y1@4(-s1eG(BoUCGGRV1-8$lEq'i68WtZx0(#kjES)Rx0X's;-fbPX60+xFH)DHSD7J2eG`XCEHst@iFkS(*H2+3pDL-4wg<I[^I370@JAD2X-9kqw'L93.-PCM*H4aFVCgfitB&weQD$i]vG42:sC?DNf16spKFD/rU1;V;iF-0I@'6'5WHThdN1ox;&&4,)*H<,MT.1<&NFJcGhL02rCIp/fQDtF+7DNm1cHQVV=-5%mW-Uhkw0-g`9C>W,<-)2kr0b`V=BnfMA&vm@uB:h_0>(B(C&%ej-$Ui$0)*ZX7D8.Rq$cveM1Y:TDFV^;dExtgS)q+>^G&>.FHN'&u-iIb*<=*`n<?mW*[0;'oDrWi=B5EFHMBV`X-Pg_%'Y3w'OvdXo$*86s)fGL,*CN,OOR3D8*)>Y?Hv,a=B=C%oDWe<kLLYfLC,o/L:ruOn*5<'_Ij5KKFCfi'/*+$kEF6iQMP[shF)bdt(@ost(j2A,MrT2,Dq=waE&g9kEeSbt(8>[['Y(+SMuoshF9d7bFvl7Y'v^i,M_v+h:U</bIbmfBdjY:f;f&I['(&x;SAVblEi;__%?=4GH*27FHq'Q-G14gvGr>9kEka[8&^oXGM[b>>B6mJB$+m@#/%*bNED&#4+8d0,HxRg6W*A0gLA)MVCkV@>%?6W8&OTPj0tG^NBkW)XB58rU1/$4m'@6dGE??@x'(.mgF4s>LFQ_08/YS@UCEsFHM4u(RB-5QhF10.%'5ocdGxs__&`mTt1^5*HEv&4RDX+]:.0PiMFn1pAG'EpKFc:L_GvA$`%x8sXBo]#lEv6;iFVqds%xD+rCNn2T&[SD3kk@S'Gq&?%&-3/:CtGxuBT0U8g<S5bH'x=<HdjeUCCrpKF(J+v'7&$lEPhCLcX']Nk@S'8DnSm`%ej[:C*K.:Cq&0`I%G5s-]['F<Jo,P1og3nDXNkF$1o;MFa7,-G3NfUCfK$Tg[m(]$?fEx'JIr*HoP0nDu42iFs&:,$]<xa$O]Ld-3@^e$J9@kEld`TCH4ml$7@e2(rOlNXb,bN1ox;&&.xn+H#CkJ-2caJ%AZ4m'Q>b#H1TpgF1sW)uBKbr.-'oFH1wWeZ>%b7MN5xc$+j#lE7_=fG.)MQ/AXnFH+G0O*=C=[97B=fGk9`9CpgH=.vRXnDi,V,2(o<GH%R)iF#HX7D4a=gG:kTNCcAZWB2x*,HO9C9&,X)pD$*A,M&bT$Hx0ddG+u3cH$YX8Im&4RDBI0W1#mMa%E44W1,gpKFpqY1F.]eFHC_nFH7<7%'E#N=BhQ/jB)3fQDl'vLFc^+F$(#lVCoic8.w2J:CVjbj(kj[:C^O.q.*-d<Bfs*u]9[it-S,^HPa?1sLXeec$rI5#H<i&gLV^8.G'xZ6'tg.>B.:OGH%i&_Sto#$G*>HlE%pN<B6]/B&wsn6D8jE<Bv=&ZGl2pgF#%SiFPpNW%q?`9Cv%,s/lF+7D'(&2FsC6.33mpOEnk,-G'ebfG?mhU19_16M),`dM/^&iFqmmt.s4/:C=^[Ht*XPgLd?/U1wo(*H^ol]8`;14+RJk#H=SvLFc+`V:_7FmBksaNEC<2dEO3j[8%2=mB2<+HMM%^9C<vFHM,^8eGpv[:C4*r$'PFr;-a0]/MF4TZ.3r*cHJ8VT.)dT4E'/h`$@6wcMO'crLuVOnM*`>>B9a,<-&>9_-iFkEIqlD<B1rrp.3g@qCJSgu(8D+7Dj#'NBqT#)/g)9NBO]uZ%u/nNBvE;9C%o<GHVTkCI-3&gL<#X1FZ/)=BxMpgFn%Jq(]W*N167lpLc[e]Gk9IbHgEbb$#&?LFv4vgFq?vsB=i1nDb<&jB,p?d$?N.EFXJitBo$9I$CtCnDM/29.-)e`%Lm%aF/lfb%F6O_I;U%:.-KFVCa=$@H$?,0CLfRV1+oR+H%3+HM&+xaFn#_(%&TJ>BqD>gCr]TSDf/#gCu)U_%7A[V1<cD.G`SM=B8GM*H6M[rL@W/eG9d)=B;d[%'3Nn*74G=UCwM#hF5A2eG#k3CI0]umDpYHaEI5FSMbWwaN]+EU/jRT0F=b?T)0.I68t%4m'lShp.JU%'I9>tx'BqhjE;j8:)#T@UCR9?:2QPUk+-n.iFT#:[/i:kjE,&YVC6Mo/1.p>LFkx0VCx>pKFqH7UC/hViFvoUEH*92=BwJ00Ff]DtB,uwFHm:/YB?pCp.2)2eG,kWe$LBwgFvS>LF-g0eM.HNhF>.JjFw.ocEwNNxH.DqoDZaK(%'ZPhF(iovG+ieBI;9`qL>]mvG8m1U13/?LF.Y8vGHT%rL>[da$>iE<B)X9GHt/_$&>vZ<_8Z9GHu#00F5Ce20?LtCIh59kEsoc3=E'0`I$:LSD%#[D%Aw?7M?B,gL6ELgEddN2B:Rg%JbxeuB3rw#Jk*mlE_aN2B(-+;CSjusB)<s=BZjSNB'KJUCF$paHvd+F$vYX7DssNcHiT&NBYZ$IHnSM<Bo0ZWBVBM@[0Z*hFxjeUCblIuB#-omDq:vgFbD#F7@S1U1;%Ia$8YtnDg1vgFRK*N1;anrLQ&TiFi[D[%&l0nDu5A>B=+?>BqJb7D%E0SDqp/@J6&Z0C'vqEH:vCU1v1rp$#=%eGA^4-MFjL$H$39kEoD;]&mcJ,MX$sgC6e:qLVDcFH$dUEH:<#W0/q:HMA2(_I?=4GH>n#gDflQN9w)ZgD62CoD.s0IMOxP<-cS?X$Au/:)M]C<-D-Xn/+^,LF6LofGNh67:Dp^>$MavcE/uU5/;c^oD2E@qL3V/eG3/?LFk2'D4m#>gC6>LSD^)YgC@%jMF@S4VCfQ$C@([-hc01HkE2E1U1ri^oD'Z9*N%i'`$Hxk)N9geoDfX@eGj6vsBl*,F%>A],M]:[A-2(DT.e#00F?L.6/K4uVC3p=HM%C>UC4I+,HI#=#H%KD$TECGR*WNnM1fO`iL4o=g.DSA>BUJ5HMm@W:/2ZX7D?m'IM]oG<-05IA-Iq.:.3mpOEj*q'&m)<&GF?,5&R,:[0$0p98W%oP'W7h,M9QP,M29MVCuoTnDaIxe>tdM<%GreV1uW+b$6O'NCoI`hF0N<?$4(x+H)>^;-GHHaMde#Y9GGZZ$#ZB8Du6^e$I^8p&:$'IZsvZt1=KkbHfH76D%pN<BeJQ,>P';q:E4=2Cd6Dv$t4oG2`V`9Ch%e&F+:+RBvSpOEs-ST%A@?lE$HX7D?l0WC&f%iF/ToUC+V3'F0QA>BC72VC2KfUC.WlpLR6U0MKW/eGq$)*HRALh,,u0VC1,k<Bvi2E%AKiDFGDRH;E#F^G2)2eG0R1[B@'f6B=xn'I0#(eMrwoTC5#Ni-5t(O=TEpm/dP;9CJEg%J3CRm/&QcdG*kIbHbr?a.A`KKFx:jf%(].Q/e#00F(C?lEnS-<-pM9kEl:s=B%IHlE(0fQD-*AfG9wFnBlI8vG,&D.GDQE^%CqhjEt&@G?UvM*e$X@X%D+s.G-TOVC$f]>BpMZQBu8_C%:5$1FW-P[MOMv50JU;iFx_moDJr<EY#5Q;Htg`9C&b;iFg$V<?)=eM1rWpmBuOhVC2(8fG;Fn;-F+WY$>7'=BnCRw9].@h*pt8S3ntUeG9DFVC(NpKFfvs2B+?fUCA6e?$+PZ1FhwuLFPa9hPVBDVClf1eG_i.>BfpAjBW+i;-`aX&=8I;s%:OOmB(WKSD5Oem/uNrTCa/)=BV,GG-N`Ul/48vLFn'VeGvTh'&,P50CFZ3sLVh-%Jto;]&o;(T.2ve:C8#)t-q7&2=c@QZ$0mX7DKm*j$Ml#hFpl2^F4OFnBh(3#G#Nq(%&H,-G5afgLNNPV1=9;eE^<Fb$,&iEHu6^e$#o3U26-G<Hh0i]$<r(*H.=G<HoKIqCH:Xw04=.FH7'g5/7rI+HdDLV:Lr;Q/w)bNEmE32B[]GKF_HjMBljeUC&t3,H)8M*HLtnoD^B&jB31GZ'K^KT.%gcdG<.d<-'&R6%x9rdGnIXHm5YcdGiKeQDo//>Bj<b$'SNVVC-glgC;_1qLa/.oD,'[`@%-4'G0]J>'1VmLFsBTU;%?W,D@@ofG`8cGDr;8>BTARQD]8:)EeJ`X':=ofG7mqU1.T^kEtf_DET[G<B_G)=B`9t^%ui.T%FicdGg>S=B3F+RBx/_C%)/2iFfH'(%:(AJGpMZ]Fq`o=B(hrpCmd2=B1G)2F`Dd<BmUJ$GG(pG2Sr:U1E4o+Hj):G$1&$lE-(rP/-l2#G(D+?'7e5gDTbW0M'onc$*06h-+tCTLet6q$;DI@';2JuB'>ZhF$+]iFuO+v'TU]6BEm3_GNreV1wkkV(ajr]GM[X(06;FVC#?pKF^coZ$`?(4Ct5/:C2<&NFnGb7Dx7S;H4m]8&BTDhD-2t<B$P=sHtYcdG0KX1<FBT*F%-C_%L;.V1)0X7D>Vvt$NQ.SD[pFq:nR?T.^';9C`r/0F2MViFo<]*$b2$d$e^nmDpi#kED#)U13JvLF=*001-g?`%eHiTCm1^L24F@Q/0u(hFhC%eG-P#GF($OcH7GqoD,C+RBn#(C%(mX7Dj'lF?9<Mj9&V/^&01=GH8&omDf3=b$+cR+Hhm%=B+,2eGd4KKF$O2=B`#&=BP04pD+-+;CgIBOEhaXb$+P`.Gp=MhF%NZw&9F4,HLTcs-fZ76Dk_IeG@,:oDW/S=BxrZ&F@7fFHjor='8FBDIHErqL'xXrL?WlFHwDHD%=VmLF#Jcw$1AViF*1GwG28$lEl>*$51gpgFqA6)%*$/:C&4><H#*fUCAip=Bp8W:/$FvsBpu-8;9i5gDIjwrLnYrsHSD&qL[omgF(46?$,-]:C*;^;-Z<J3%ah+?.#klUCh?H<BLgBq7580tq@[Pj;vxSr-DlLO+rdb5/<]>UCPu^5NlcUcH$V)F4c7T0Fum.>Bsu>kE980[HlGH&F:';qLJ9Q-.LN7rLRdlFHu$AiFR&;GH$NqC%A='SB1%KZG&ZfYBi$Q<Bwk%2F)+c<HT9Qq2GGnrLHQwKDlVrt'cr=fE3=PsHD&2U1iwwa$+BXVC^BD<B:,5-Mk]X,1sN76D^DtmD,M<?JuI*QBrEZwAM@O2C/Ol1N-ErVC+<SgLB*:$JuLBEFSNM<BA4oFH`(l#H;CDVC?ZerLXvQb<fNh0,f-]V1nov`%0cD.GEZS5'jcpO1vMFVCnhTSD$QxUCnVKnD(P/#'[9Fp.eQ%UCEs(U1/gnSD&B]UCeer2%LtnfGs2$@&,Av-G?r>LFCud'O32dT%j^M,D-6A>BpM=UCC%fV1(8$PEk`CHD:=0%J5`1eG,&;HD3pOVCNThV%v1:dDk2'kEkS(dD+J;iFuT7FHs,$D%E5DU1#,<&&pZ3nD'>ZhF0'D(&ome_G8CffG#WQ%&'BXVC/S7FH(*D(&Nh1nD$DJvG$pN<Bv=SvG1(^b%+bDPE0.LEFp_DPEwGX7DI)R#5Kk7fGZBO'%'-=nDj+&vG..#wG0dxYB'N_lLHOP,Mw6T=B$=5F%>CvhFjrW<UnGb'%[2V,2&b;iF&]J;Hm#6`%vMFVCps.[$e5#hFp.mgFHlnhW&3INBl';9CDl'oDUN8jBurL*Hgu#kEsjitBwf^m_=w*R/uvNcHkWBC%Z:OOCaQf*$app$&hQrXB-'8UC4V[q$/p.:C1d1U1,8-W-p>E*[>7'=B/8jF5?x1,HjMlGD0v,hF8/jEIWC&qLCC,Y'v#9W-mQE9rpV0c$r$,R<*x0VC152eG$ZQt.-?0@J.f-LYT@-thN4MU1q6s;-Qe5-MN+f^$M9ofG)x09IRmJt9DrMw$oGtnDfdANBAq1qLiRhjE+tLC&>FvLF&*i_&a,$&J_WofCbD(dD-rI+H2,VqL8'?D-vX1h&7$sS&Vx^?HJ*+pDji%>'-))iFF7XjC)'W=BYmmJXIKMm$C/j#>OTgJ)m-I-M.:Uq@#[at(mWvV^Q6`eMRFd-&b,-<-.T9kE3YcQDa&?%&+nitBlmnmDd#&=BBCwgF;1K%J<(ZW-S]:w^1[%iF(NZw&#B#hFF($edVqDmEbIcdGv`KKFgn_aHhPZD%$8vB82`DA&E44W1=(x+HdU#(=v`(Z[0'MHMBD#/G$)qkEFB:hG<1D*HG:)*H:MYn*/a)=BorAqV.;h;-E_VX-Sc)F.$V=UCS0'IQ;i,ZHA7S[Pclq@-H'J:.&sGPE&lCvHL,xrL[ErP-oc[m-01;N;5Co6M&QXaE7D`*H(a-F.XHBuA#<adGERF,Hmw$q$ZHap&<cD.Grv&<-6@iT.-^,-GqsOg$`m`>$O8O>H>74r$+6[L2TqxV%w2xS&8Kr3=g9`Y9rtdh,v>[0Y-9^e$6XZ;%C0hNCA$###$)>>#SlRfL0ecgL4KihL2UR6/e<H;#X:OGM9]sfLtwSfL$;5ci1jAFM$_['Vqr)##G1Z'V&2@AtvbapF"