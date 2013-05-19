--NowState 0:Normal, 1:Down, 2:Disable, 3:Hover

local function SetState(self, newState)
    local attr = self:GetAttribute()
    local boxBkg = self:GetControlObject("boximage")
	if newState == 0 then
		boxBkg:SetResID(attr.BoxNormalIconID)
	elseif newState == 1 then
		boxBkg:SetResID(attr.BoxDownIconID)
	elseif newState == 2 then
		boxBkg:SetResID(attr.BoxDisableIconID)
	elseif newState == 3 then
		boxBkg:SetResID(attr.BoxHoverIconID)
	end
	
	attr.NowState = newState
end

function SetCheck(self, check, bClick, notFireEvent)	--bClick:是否是鼠标单击导致的状态改变	-- notFireEvent:是否要触发OnCheck事件
	if bClick == nil then
		bClick = false
	end
    local c = check
    if c == nil then
        c = false
    end
    
    if c == self:GetCheck() then
        return
    end
    
	local tickBkg = self:GetControlObject("tickimage")
    local attr = self:GetAttribute()
    attr.Check = c
    if self:GetEnable() then
		if bClick and attr.Animationed then
			if attr.AniPos == nil then
				local left,top,right,bottom = tickBkg:GetObjPos()
				if attr.Check then
				    attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = (left+right)/2,(top+bottom)/2,(left+right)/2,(top+bottom)/2
				else
				    attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = left,top,right,bottom
				end
			else
				attr.AniPos:Stop()
				attr.AniPos = nil
				local left,top,right,bottom = tickBkg:GetObjPos()
				attr.curLeft,attr.curTop,attr.curRight,attr.curBottom = left,top,right,bottom
			end
			
			SetState(self,0)
			local ownerTree = self:GetOwner()
			tickBkg:SetResID(attr.TickNormalIconID)
			tickBkg:SetVisible(true)
			local templateManager = XLGetObject("Xunlei.UIEngine.TemplateManager")	
			local posAniTemplate = templateManager:GetTemplate("checkbox.showani","AnimationTemplate")
			local instance = posAniTemplate:CreateInstance()
			if instance then
				if attr.Check then
					instance:SetKeyFrameRect(attr.curLeft,attr.curTop,attr.curRight,attr.curBottom,attr.initLeft,attr.initTop,attr.initRight,attr.initBottom)
				else
					instance:SetKeyFrameRect(attr.curLeft,attr.curTop,attr.curRight,attr.curBottom,(attr.initLeft+attr.initRight)/2,(attr.initTop+attr.initBottom)/2,(attr.initLeft+attr.initRight)/2,(attr.initTop+attr.initBottom)/2)
				end
				instance:BindLayoutObj(tickBkg)
				ownerTree:AddAnimation(instance)
				local function onAniFinish(self,old,new)
                    if new == 4 then
                        attr.AniPos = nil
                        tickBkg:SetObjPos(attr.initLeft,attr.initTop,attr.initRight,attr.initBottom)
                        if attr.Check  then
                            tickBkg:SetVisible(true)
                        else
                            tickBkg:SetVisible(false)
                        end
                    end
                end
        
                instance:AttachListener(true ,onAniFinish)
				instance:Resume()
				attr.AniPos = instance
			end
		else
			SetState(self,0)
			if attr.Check  then
				tickBkg:SetVisible(true)
			else
				tickBkg:SetVisible(false)
			end
		end
    else
        SetState(self,2)
		if attr.Check  then
            tickBkg:SetVisible(true)
        else
            tickBkg:SetVisible(false)
        end
    end
	
	if notFireEvent == nil or notFireEvent == false then
		self:FireExtEvent("OnCheck",attr.Check, bClick)
	end
end

function GetCheck(self)
    local attr = self:GetAttribute()
    return attr.Check
end

function SetText(self, text)
	local attr = self:GetAttribute()
	attr.Text = text
	textobj = self:GetControlObject("checktext")
	textobj:SetText(attr.Text)
end

function GetText(self)
	local attr = self:GetAttribute()
	return attr.Text;
end


function OnInitControl(self)
    local attr = self:GetAttribute()
	
	local textObj = self:GetControlObject("checktext")
    if attr.Text then
        textObj:SetText(attr.Text)
    end
	
	if  attr.Wordellipsis == 1 then
		textObj:SetEndEllipsis(true)
	end

	textObj:SetTextColorResID(attr.TextColor)
	textObj:SetTextFontResID(attr.TextFont)
	
    local boxBkg = self:GetControlObject("boximage")
    boxBkg:SetResID(attr.BoxNormalIconID)
    local tickBkg = self:GetControlObject("tickimage")
    tickBkg:SetResID(attr.TickNormalIconID)
    tickBkg:SetVisible(attr.Check)
	local left,top,right,bottom = tickBkg:GetObjPos()
	attr.initLeft,attr.initTop,attr.initRight,attr.initBottom = left,top,right,bottom
	
	OnVisibleChange(self, self:GetVisible())
end

function OnLButtonDown(self, x, y, flags)
	local attr = self:GetAttribute()

	SetState(self,1)
	self:SetCaptureMouse(true)
	local ret = self:FireExtEvent("OnCheckBoxLButtonDown")
	if ret == false then
		SetState(self,0)
		self:SetCaptureMouse(false)
	end

	return 0
end

function OnLButtonUp(self, x, y, flags)
	local attr = self:GetAttribute()

	if attr.NowState==1 then
		local ret = self:FireExtEvent("OnBeforeClick")
		if ret~= false then
			self:SetCheck(not attr.Check, true)
		end
	end
	self:SetCaptureMouse(false)

	return 0
end

function OnMouseMove(self,x,y,flags)
    local attr = self:GetAttribute()

	if attr.NowState==0 then
		SetState(self,3)
	end
	self:FireExtEvent("OnMouseEvent","OnMouseMove", x, y, flags)

    return 0
end

function OnMouseLeave(self,x,y,flags)
    local attr = self:GetAttribute()

	SetState(self,0)
	self:FireExtEvent("OnMouseEvent","OnMouseLeave", x, y, flags)

	return 0
end

function OnMouseWheel(self, x, y, flags)
	local attr = self:GetAttribute()

	self:FireExtEvent("OnMouseEvent","OnMouseWheel", x, y, flags)

	return 0
end

function OnChar(self, char, repeatCount, flags)
    if char == 32 or char == 13 then
		local ret = self:FireExtEvent("OnBeforeClick")
		if ret ~= false then
			local attr = self:GetAttribute()
			self:SetCheck(not attr.Check, true)
		end
    elseif char == 9 then
        self:RouteToFather()
    end
	return 0, true, true
end

function AddTip(ctrl, text, sessionName, type_)
    XLGetGlobal("xunlei.TipsHelper"):AddTip(ctrl, text, sessionName, type_)
end

function RemoveTip(ctrl)
    local id = ctrl:GetID()
    local tipid = id..".tip"
    local tip = ctrl:GetControlObject(tipid)
    if tip ~= nil then
        ctrl:RemoveChild(tip)
    end
    return tipid
end

function SetTickImage(self, imageID, drawmode, x, y)
	local tickBkg = self:GetControlObject("tickimage")
	tickBkg:SetDrawMode(drawmode)
	tickBkg:SetResID(imageID)
	tickBkg:SetObjPos(0, 0, 19, 19)  --tickBkg的默认位置
	if drawmode == 0 then
		local bitmap = tickBkg:GetBitmap()
		local color,bmpwidth,bmpheight,len = bitmap:GetInfo()
		local left, top, right, bottom = tickBkg:GetObjPos()
		if x ~= nil then
			left = x
		end
		if y ~= nil then
			top = y
		end
		tickBkg:SetObjPos(left, top, left+bmpwidth, top+bmpheight)
	end
end

function OnFocusChange(self, focus)
	if not focus then
		self:RemoveTip()
	end
	local checktext = self:GetControlObject("checktext")
	local attr = self:GetAttribute()
	if checktext == "" or checktext == nil then
		attr.ShowFocusRect = false
	end
	local focusrect = self:GetControlObject("focusrectangle")
	if not attr.ShowFocusRect then
		focusrect:SetVisible(false)
	else
		local checktext = self:GetControlObject("checktext")
		local l, t, r, b = focusrect:GetObjPos()
		local w, h = checktext:GetTextExtent()
		focusrect:SetObjPos(l, t, l + w + 18, b)
		focusrect:SetVisible(focus)
	end
end

function OnEnableChange(self, enable)

	local tickBkg = self:GetControlObject("tickimage")
	local objText = self:GetControlObject("checktext")
	local attr = self:GetAttribute()
    if not enable then
        SetState(self,2)
		objText:SetTextColorResID(attr.DisableTextColor)
		tickBkg:SetResID(attr.TickDisableIconID)
		if attr.Check  then
            tickBkg:SetVisible(true)
        else
            tickBkg:SetVisible(false)
        end
    else
        SetState(self,0)
		objText:SetTextColorResID(attr.TextColor)
		tickBkg:SetResID(attr.TickNormalIconID)
		if attr.Check  then
            tickBkg:SetVisible(true)
        else
            tickBkg:SetVisible(false)
        end
    end
end

function OnVisibleChange(self, visible)
	-- self:SetVisible(visible)
	self:SetChildrenVisible(visible)
end