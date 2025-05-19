-- 📦 Script complet avec GUI néon, vérification clé en ligne, Fly/Noclip/ESP

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

-- 📁 Clé API GitHub
local GIST_RAW_URL = "https://gist.githubusercontent.com/zarrarim/8294bb07673379bcfa80cf594fe641a3/raw/5dfd8893189a507fc0912e5354da671848a7d70a/roblox-key-auth.json"

-- 🔑 Vérification clé
local function isKeyValid(key)
	local success, response = pcall(function()
		return HttpService:GetAsync(GIST_RAW_URL)
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		for _, validKey in ipairs(data.valid_keys) do
			if validKey == key then
				return true
			end
		end
	else
		warn("Erreur HTTP : " .. tostring(response))
	end
	return false
end

-- 🌈 GUI de connexion
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "KeySystemUI"
gui.ResetOnSpawn = false

local blur = Instance.new("BlurEffect", workspace.CurrentCamera)
blur.Size = 12

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 400, 0, 220)
frame.Position = UDim2.new(0.5, -200, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.2
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 255)

local title = Instance.new("TextLabel", frame)
title.Text = "🔐 Entrez votre clé"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20

local input = Instance.new("TextBox", frame)
input.PlaceholderText = "Ex: MaCleSecrete123"
input.Size = UDim2.new(0.8, 0, 0, 40)
input.Position = UDim2.new(0.1, 0, 0.4, 0)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
input.TextColor3 = Color3.new(1, 1, 1)
input.TextSize = 18
input.Font = Enum.Font.GothamSemibold
Instance.new("UICorner", input)

local confirm = Instance.new("TextButton", frame)
confirm.Text = "✅ Valider"
confirm.Size = UDim2.new(0.5, 0, 0, 40)
confirm.Position = UDim2.new(0.25, 0, 0.7, 0)
confirm.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
confirm.TextColor3 = Color3.new(1, 1, 1)
confirm.Font = Enum.Font.GothamBold
confirm.TextSize = 20
Instance.new("UICorner", confirm)

-- 🌟 UI principale après validation
local menu = Instance.new("Frame", gui)
menu.Visible = false
menu.Size = UDim2.new(0, 200, 0, 200)
menu.Position = UDim2.new(0, 10, 0.5, -100)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Instance.new("UICorner", menu)

local function createToggleButton(text, yPos)
	local btn = Instance.new("TextButton", menu)
	btn.Size = UDim2.new(1, -20, 0, 40)
	btn.Position = UDim2.new(0, 10, 0, yPos)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	Instance.new("UICorner", btn)
	return btn
end

local flyBtn = createToggleButton("Fly [F]", 10)
local noclipBtn = createToggleButton("Noclip [N]", 60)
local espBtn = createToggleButton("ESP [E]", 110)

-- 🛩️ Fly
local flyEnabled = false
local function fly()
	local hrp = character:WaitForChild("HumanoidRootPart")
	local bv = Instance.new("BodyVelocity", hrp)
	local bg = Instance.new("BodyGyro", hrp)
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	
	RunService.RenderStepped:Connect(function()
		if flyEnabled then
			local move = Vector3.new()
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
			bv.Velocity = move.Unit * 60
			bg.CFrame = camera.CFrame
		else
			bv:Destroy()
			bg:Destroy()
		end
	end)
end

-- 🚪 Noclip
local noclip = false
RunService.Stepped:Connect(function()
	if noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- 👁️ ESP avancé
local function enableESP()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local adornee = plr.Character.HumanoidRootPart
			local esp = Instance.new("BillboardGui", adornee)
			esp.Name = "ESP"
			esp.Size = UDim2.new(0, 100, 0, 40)
			esp.Adornee = adornee
			esp.AlwaysOnTop = true

			local label = Instance.new("TextLabel", esp)
			label.Size = UDim2.new(1, 0, 1, 0)
			label.Text = plr.DisplayName .. " (" .. math.floor((plr.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude) .. "m)"
			label.TextColor3 = Color3.fromRGB(255, 60, 60)
			label.BackgroundTransparency = 1
			label.TextScaled = true
		end
	end
end

-- 🔘 Boutons
flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then fly() end
end)

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
end)

espBtn.MouseButton1Click:Connect(function()
	enableESP()
end)

-- 🧠 Valider la clé
confirm.MouseButton1Click:Connect(function()
	if isKeyValid(input.Text) then
		frame.Visible = false
		menu.Visible = true
		blur:Destroy()
	else
		input.Text = "❌ Mauvaise clé"
	end
end)

