-------------------------------Variaveis globais--------------------------------------------------------------------------------
progLines = {}
functionsTable = {}
stackExecution = {}
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Auxiliares---------------------------------------------------------------
-- Retona um vetor com os valores inicializados com 0's
function initializeVectorWithZeros(vectorSize)
	local myVector = {}
	for i = 1, vectorSize do
		myVector[i] = 0
	end
	return myVector
end

--Imprime o conteúdo da tabela de funções
function printfunctionsTable()
	for i = 1, #functionsTable do 
		print(functionsTable[i].name, functionsTable[i].pos, functionsTable[i].bodyBegin, functionsTable[i].bodyEnd)
	end
end

--Imprime o conteúdo do vetor
function printVector(myVector)
	for i = 1, #myVector do
		print(myVector[i])
	end
end

--Verifica se o indice que está tentando ser acessado existe. Caso não exista retornar mensagem de erro.
function verifyArrayOutBounds()

	--print("Erro: o índice acessado está fora dos limites do array")
end

function debugLine(...)
	print(...)
end

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Regex--------------------------------------------------------------------
--Remove os comenários que estão após o //
function removeComments(line)
	--debugLine(string.match(line, "[^//]*"))
	return string.match(line, "[^//]*")
end

function removeInitialWhiteSpaces(str)
	--Pego a quantidade inicial de espaços em branco 
	local initialWhiteSpaces = string.match(str, "^%s*")
	local finalWhiteSpaces = string.match(str, "%s*$")
	--Removo os espaços em branco presentes no inicio da string
	local myStr = string.gsub(str, initialWhiteSpaces, "", 1) 
	return myStr
end


--Pega o nome da variável seja ela uma variável simples ou um vetor
function getVariableName(lineNumber)
	--Pego tudo após a palavra "var" + n characteres em branco até o primeiro caracter "[" (caso ele exista).
	local str = string.match(progLines[lineNumber], "var%s+[^%[]*")

	--debugLine(string.gsub(varName, "%s+", "."))
	--Removo o "var" + caracteres em branco que restou no inicio da string
	--local varName = string.gsub(str, "var%s+", "") 
	local varName = removeReservedWordAndAllWhiteSpaces("var", str)
	return varName
end

--Pega o valor da variável
function getVariableValue(lineNumber)
	local varValue = tonumber( string.match(progLines[lineNumber], " %d+") )
	return varValue
end

--Pega o tamanho do vetor que foi declarado
function getVectorSize(lineNumber)
	local vectorSize = tonumber( string.match(progLines[lineNumber], "%[(%d+)%]") )
	return vectorSize
end

--Verifica se a variável é um número ou vetor. Se for número o retorna true, se vetor, false.
function isVariableANumber(lineNumber)
	local str = string.find(progLines[lineNumber], "%[")
	--Se for nil então não existe o caractere "[", então é é um número comum, caso contrário é um vetor
	if str == nil then 
		return true
	else
		return false
	end
end

--Pega o nome da função presente na linha
function getFunctionName(line)
	--Pego tudo depois do espaço em branco após a palavra "function" até o primeiro caracter "("
	local str = string.match(line, "function%s+[^%(]*")
	--Removo a palavra "function" e os espaços em branco que existirem
	local functionName = removeReservedWordAndAllWhiteSpaces("function", str)
	return functionName
end


function removeReservedWordAndAllWhiteSpaces(reservedWord, str)
	local regexPattern = reservedWord.."%s+"
	--Removo a palavra reservada (var, function e outras)
	local wihoutReservedWord = string.gsub(str, regexPattern, "") 
	local wihoutReservedWordAndWhiteSpace = string.gsub(wihoutReservedWord, "%s*", "") 
	return wihoutReservedWordAndWhiteSpace

end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Principais---------------------------------------------------------------

--Abre o arquivo e salva ele localmente na variavel global progLines
function prepareFile()
	-- Pega o nome do arquivo passado como parâmetro (se houver)
	local filename = "./testes/teste8.bpl"
	if not filename then
	   print("Usage: lua interpretador.lua <prog.bpl>")
	   os.exit(1)
	end

	local file = io.open(filename, "r")
	if not file then
	   print(string.format("[ERRO] Cannot open file %q", filename))
	   os.exit(1)
	end
	--Salva o arquivo na variavel global progLines
	saveFile(file:lines())

	file:close()
end	

--Salva o arquivo na variavel global progLines. Observe que ele será salvo com os comentários removidos
function saveFile(file)
	for line in file do
		local tempStr = removeComments(line)
		tempStr = removeInitialWhiteSpaces(tempStr)
		progLines[#progLines + 1] = tempStr
		--debugLine(tempStr)
	end
end

--Procura pelas funções existentes no programa e salva a linha onde elas estão declaradas na "functionsTable"
function identifyFunctions()
	for i = 1, #progLines do 
  		if string.find(progLines[i], "function") ~= nil then			
			functionsTable[#functionsTable + 1] = { ["name"] = getFunctionName(progLines[i]), ["pos"] = i+1}
		end
	end
end

--Retorna os dados da função presentes na functionsTable
function getFunctionDataInFunctionsTable(functionName)
	for i = 1, #functionsTable do 
		if (functionsTable[i].name == functionName) then
			return functionsTable[i].pos, functionsTable[i].bodyBegin, functionsTable[i].bodyEnd  
		end
	end
end

--Executa a função passada como parametro
function executeFunction(functionName)
	local stackPosition = #stackExecution + 1
	local funcPosition, bodyBegin, bodyEnd = getFunctionDataInFunctionsTable(functionName)

	-- if isThereParametersInThisFunction(funcPosition) then
	-- end
	--declareParameters(funcPosition,stackPosition)
	--
	--Inicializando a estrutura da função
	stackExecution[stackPosition] = {}
	initializeReturnValue(stackPosition)
	declareVariables(funcPosition,stackPosition)
	executeFunctionBody(bodyBegin, bodyEnd)

end

-- Executa o conteúdo presente no corpo da função, observe que esse conteúdo se inicia 1 linha após o "begin" e finaliza 1 linha antes do "end"
function executeFunctionBody(bodyBegin, bodyEnd)
	for lineNumber = bodyBegin + 1, bodyEnd - 1 do 
		if verifyAction(lineNumber) == "attribuition" then
			resolveAttribuition(lineNumber)
		elseif verifyAction(lineNumber) == "comparation" then
			resolveComparation(lineNumber)
		elseif verifyAction(lineNumber) == "functionCall" then
			resolveFunctionCall(lineNumber)
		else
			print("Erro na execução do corpo")
		end
	end
end

--Verifica qual é a ação (atribuição, chamada de função, ou comparação)presente na linha 
function verifyAction(lineNumber)
	local myStr = progLines[lineNumber]
	if string.match(myStr, " = ") == " = " then
		return "attribuition"
	elseif string.match(myStr, "if ") == "if " then
		return "comparation"
	elseif string.match(myStr, "%(") == "(" then
		return "functionCall"
	else
		return "error"
	end
end

--Resolve atribuição
function resolveAttribuition(lineNumber)
	print(progLines[lineNumber], "atribuição")
end

--Resolve comparação (IF-ELSE)
function resolveComparation(lineNumber)
	print(progLines[lineNumber], "comparação")
end

--Resolve chamada de função
function resolveFunctionCall(lineNumber)
	print(progLines[lineNumber], "chamada de função")
end

--Inicializa o valor de retorno de uma função com 0
function initializeReturnValue(stackPosition)
	stackExecution[stackPosition]["ret"] = 0
end


--Salva as variáveis (na estrutura da função) dentro da stackExecution
function declareVariables(funcPosition, stackPosition)
	--Se existir variáveis na função elas serão salvas na estrutura presente na stackExecution
	if (isThereVariablesInThisFunction(funcPosition)) then
		local simpleVariablesValues, vectorVariablesValues = getVariablesList(funcPosition)
		stackExecution[stackPosition]["simpleVariables"] = simpleVariablesValues
		stackExecution[stackPosition]["vectorVariables"] = vectorVariablesValues
	end
end


--Verifica se a função possui variáveis.
function isThereVariablesInThisFunction(lineNumber)
	--Se existir a palavra "begin" quer dizer que não há variáveis locais.
	if (isThere_BEGIN_InThisLine(lineNumber)) then
		return false
	else
		return true
	end
end

--Verifica se a linha atual contém a palavra "begin"
function isThere_BEGIN_InThisLine(lineNumber)
	local str = string.match(progLines[lineNumber], "^begin")
	if (str == "begin") then 
		return true
	else
		return false
	end	
end

--Verifica se a linha atual contém a palavra "end"
function isThere_END_InThisLine(lineNumber)
	local str = string.match(progLines[lineNumber], "^end")
	if (str == "end") then 
		return true
	else
		return false
	end	
end

--Retorna uma lista com as variáveis(simples e vetores) declaradas e inicializadas com 0's
function getVariablesList(lineNumber)
	local simpleVariables = {}
	local vectorVariables = {}
	--Se não há "begin" quer dizer que ainda estamos em uma linha que contém as declarações das variáveis
	while (not isThere_BEGIN_InThisLine(lineNumber)) do

		if isVariableANumber(lineNumber) then
			local nameField = getVariableName(lineNumber)
			--Como na declaração da variável não há valor iremos iniciar com 0--Isso está sendo pedido no trabalho
			local value = 0
			--Os valores serão armazenados em um campo com o nome da variável
			simpleVariables[nameField] = value

		else
			local nameField = getVariableName(lineNumber)
			local vectorSize = getVectorSize(lineNumber)
			--Como na declaração da variável não há valor iremos iniciar o vetor com 0's--Isso está sendo pedido no trabalho
			local vectorValues = initializeVectorWithZeros(vectorSize)
			vectorVariables[nameField] = {size = vectorSize, values = vectorValues}
		end
		lineNumber = lineNumber + 1
	end
	return simpleVariables, vectorVariables
end

-- function isThereParametersInThisFunction(lineNumber)
-- 	if
-- 	return true
-- end

--Salva na tabela de funções o local de inicio e fim do corpo da função. 
function identifyBodyFunction()
	for i = 1, #functionsTable do 
		local funcPosition = functionsTable[i].pos
		functionsTable[i]["bodyBegin"] = searchFunctionBody_BEGIN(funcPosition)
		functionsTable[i]["bodyEnd"] = searchFunctionBody_END(funcPosition)
	end
end

--Identifica em qual linha inicia o corpo da função. O início é demarcado pela palavra reservada "begin"
function searchFunctionBody_BEGIN(funcPosition)
	for lineNumber = funcPosition, #progLines do
		if isThere_BEGIN_InThisLine(lineNumber) then
			return lineNumber
		end
	end
end

--Identifica em qual linha finaliza o corpo da função. O fim é demarcado pela palavra reservada "end"
function searchFunctionBody_END(funcPosition)
	for lineNumber = funcPosition, #progLines do
		if isThere_END_InThisLine(lineNumber) then
			return lineNumber
		end
	end
end


--Faz o pré processmento
--Salva o arquivo lido na tabela "progLines" e procura pelas funções existentes no programa e as salva em "functionsTable"
function preProcessing()
	prepareFile()
	identifyFunctions()
	identifyBodyFunction()
	printfunctionsTable()--REMOVER DEPOIS ESSA LINHA**********************************************************************************
end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


------------------------Execução do Programa principal-------------------------------------------------------------------------
preProcessing()


executeFunction("main")

print("stackExecutionSize: ", #stackExecution)

local pretty = require('pl.pretty')
pretty.dump(stackExecution)
pretty.dump(functionsTable)
pretty.dump(progLines)

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
