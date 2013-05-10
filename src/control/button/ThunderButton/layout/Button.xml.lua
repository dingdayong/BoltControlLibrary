
function SetState(self, newState, forceUpdate, noAni)
    local attr = self:GetAttribute()
	local textObj = self:GetControlObject("button.text")
	
    if forceUpdate or newState ~= attr.NowState then
        local ownerTree = self:GetOwner()
        local oldBkg = self:GetControlObject("button.oldbkg")
        local bkg = self:GetControlObject("button.bkg")
		local old_texture_id = bkg:GetTextureID()
		local btntextheight = "father.height"
		if attr.NormalBkgID == "general.button.normal" then
			btntextheight = "father.height-1"
		end
		textObj:SetObjPos2(0,0,"father.width",btntextheight)
        if newState == 0 then
            if attr.IsDefaultButton then
                bkg:SetTextureID(attr.DefaultBkgNormal)
                --SetDefaultAnimation(self)
            else
                bkg:SetTextureID(attr.NormalBkgID)
            end
			
        elseif newState == 1 then
            if attr.IsDefaultButton then
                --RemoveDefaultAnimation(self)
            end
            if attr.IsDownModifyPos then
                textObj:SetObjPos2(1,1,"father.width",btntextheight)
            end
            bkg:SetTextureID(attr.DownBkgID)
        elseif newState == 2 then
                bkg:SetTextureID(attr.DisableBkgID)
        elseif newState == 3 then
            if attr.IsDefaultButton then
                --RemoveDefaultAnimation(self)
            end
            bkg:SetTextureID(attr.HoverBkgID)
        end

		if noAni == nil then
            oldBkg:SetTextureID(old_texture_id)
		    oldBkg:SetAlpha(255)
			local aniFactory = XLGetObject("Xunlei.UIEngine.AnimationFactory")	
			local aniAlpha = aniFactory:CreateAnimation("AlphaChangeAnimation")
			aniAlpha:BindRenderObj(oldBkg)
			aniAlpha:SetTotalTime(200)
			aniAlpha:SetKeyFrameAlpha(255,0)
			ownerTree:AddAnimation(aniAlpha)
			aniAlpha:Resume()
		end
		attr.NowState = newState
    end
end





function SetBitmap( self, nor, down, hover, disable )
	local attr = self:GetAttribute()
	attr.NormalBkgID = ""
	if nor ~= nil then
		attr.NormalBkgID = nor
	end
	attr.DownBkgID = ""
	if down ~= nil then
		attr.DownBkgID = down
	end
	attr.DisableBkgID = ""
	if disable ~= nil then
		attr.DisableBkgID = disable
	end
	attr.HoverBkgID = ""
	if hover ~= nil then
		attr.HoverBkgID = hover
	end
	self:SetState(attr.NowState, true, true)
end

function SetText(self, text)
    if text == nil then
        return
    end
    local textObj = self:GetControlObject("button.text")
    textObj:SetText(text)
    local attr = self:GetAttribute()
    attr.Text = text
end

function GetText(self)
    local attr = self:GetAttribute()
	return attr.Text
end

function OnLButtonDown(self, x, y)
    local attr = self:GetAttribute()
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    if not attr.UseValidPos then
        attr.ValidWidth = width
        attr.ValidHeight = height
    end
	
	if ((x >= attr.ValidLeft) and (x <= attr.ValidLeft + attr.ValidWidth) and (y >= attr.ValidTop) and (y <= attr.ValidTop + attr.ValidHeight)) then
		self:SetState(1)
		self:SetCaptureMouse(true)
		attr.BtnDown = true
	end
	
	self:FireExtEvent("OnButtonMouseDown")
    return 0
end

function OnLButtonUp(self)
    local attr = self:GetAttribute()
    if self:GetEnable() then
        if attr.NowState==1 then
			self:SetState(0)
            self:FireExtEvent("OnClick")
        end
        self:SetCaptureMouse(false)
        attr.BtnDown = false
    end
    return 0
end

function OnKeyDown(self, char)
	if char == 32 or char == 13 then
        local attr = self:GetAttribute()
        if self:GetEnable() then
			self:FireExtEvent("OnClick")
		end
    end
	return 0
end

function OnKeyUp(self, char)
    if char == 9 then
        self:RouteToFather()
    end
    return 0
end

function OnMouseMove(self, x, y)
    local left, top, right, bottom = self:GetObjPos()
    local width, height = right - left, bottom - top
    
    local attr = self:GetAttribute()
    if not attr.UseValidPos then
        attr.ValidWidth = width
        attr.ValidHeight = height
    end
	
	if ((x >= attr.ValidLeft) and (x <= attr.ValidLeft + attr.ValidWidth) and (y >= attr.ValidTop) and (y <= attr.ValidTop + attr.ValidHeight)) then
		if attr.NowState==0 then
			if attr.BtnDown then
				self:SetState(1)
			else
				self:SetState(3)
			end
		end
	else
		if attr.ChangeStateWhenLeave then
			self:SetState(0)
		end
	end
	self:FireExtEvent("OnButtonMouseMove", x, y)

    return 0
end

function OnMouseLeave(self, x, y)
    local attr = self:GetAttribute()
    if self:GetEnable() then
        self:SetState(0)
    else
        self:SetState(2)
    end
    self:FireExtEvent("OnButtonMouseLeave", x, y)
    return 0
end


function OnFocusChange( self, focus )
	local attr = self:GetAttribute()
	local focusrect = self:GetControlObject("focusrectangle")
	if focusrect then
		if not attr.ShowFocusRect or not self:GetEnable() then
			focusrect:SetVisible(false)
		else
			if attr.FocusRectWidth ~= 0 and attr.FocusRectHeight ~= 0 then
				focusrect:SetObjPos(attr.FocusRectLeft, attr.FocusRectTop, attr.FocusRectLeft+attr.FocusRectWidth, attr.FocusRectTop+attr.FocusRectHeight)
			end
			focusrect:SetVisible(focus)
		end
	end
end

function OnInitControl(self)
    local attr = self:GetAttribute()
	
    OnVisibleChange(self, self:GetVisible())
    self:SetText(attr.Text)
	self:SetTextColor(attr.TextColor)
	self:SetTextFont(attr.TextFont)
    attr.NowState=0
    local bkg = self:GetControlObject("button.bkg")
    bkg:SetTextureID(attr.NormalBkgID)
    --SetDefaultAnimation(self)
	    
    local left, top, right, bottom = self:GetObjPos()
    
    if not attr.ValidLeft then
        attr.ValidLeft = 0
    end
    if not attr.ValidTop then
        attr.ValidTop = 0
    end
    if not attr.ValidWidth then
        attr.ValidWidth = right - left
    end
    if not attr.ValidHeight then
        attr.ValidHeight = bottom - top
    end
	
    local oldbkg = self:GetControlObject("button.oldbkg")
	oldbkg:SetObjPos(attr.SpaceMagrin, 0, "father.width-" .. attr.SpaceMagrin, "father.height")
	
    if attr.NormalBkgID == "general.button.normal" then
        local textobj = self:GetControlObject("button.text")
        if textobj then
            textobj:SetObjPos(0,0,"father.width","father.height-1")
        end
    end
end

function SetSpaceMagrin(self, magrin)
    if magrin == nil then
        return
    end
    local oldbkg = self:GetControlObject("button.oldbkg")
	oldbkg:SetObjPos(magrin, 0, "father.width-" .. magrin, "father.height")
end

function SetTextColor(self, color)
    if color == nil then
        return
    end
    local attr = self:GetAttribute()
	attr.TextColor = color
    local textObj = self:GetControlObject("button.text")
    textObj:SetTextColorResID(color)
end

function SetTextFont(self, font)
    if font == nil then
        return
    end
    local attr = self:GetAttribute()
	attr.TextFont = font
    local textObj = self:GetControlObject("button.text")
    textObj:SetTextFontResID(font)
end


function SetTextPos(self, left, top, width, height)
	local textObj = self:GetControlObject("button.text")
	textObj:SetObjPos(left, top, left + width, top + height)
end

function GetTextWidth(self)
    local textObj = self:GetControlObject("button.text")
	return textObj:GetTextExtent()
end


function SetDefaultButton(self, isdefault)
    local attr = self:GetAttribute()
    if isdefault == attr.IsDefaultButton then
        return
    end
    attr.IsDefaultButton = isdefault
    --SetDefaultAnimation(self)
    self:SetState(attr.NowState, true)
end

function OnEnableChange(self, enable)
	local attr = self:GetAttribute()
    local bkg = self:GetControlObject("button.bkg")
	local text = self:GetControlObject("button.text")
    if enable then
        if attr.IsDefaultButton then
            bkg:SetTextureID(attr.DefaultBkgNormal)
        else
		    bkg:SetTextureID(attr.NormalBkgID)
		end
		attr.NowState = 0
		text:SetTextColorResID(attr.TextColor)
    else
		local focusrect = self:GetControlObject("focusrectangle")
		focusrect:SetVisible(false)
		bkg:SetTextureID(attr.DisableBkgID)
		attr.NowState = 2
		text:SetTextColorResID(attr.DisableTextColor)
    end
end

function OnVisibleChange(self, visible)
	local attr = self:GetAttribute()
    -- self:SetVisible(visible)
    self:SetChildrenVisible(visible)
	local focusrect = self:GetControlObject("focusrectangle")
	
	local nowvisible = focusrect:GetVisible()
	if not attr.ShowFocusRect then
		focusrect:SetVisible(false)
		focusrect:SetAlpha(0)
	end
end