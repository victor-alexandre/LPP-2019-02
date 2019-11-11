-------------------------------Variaveis globais--------------------------------------------------------------------------------
pretty = require('pl.pretty')
progLines = {}
functionsTable = {}
stackExecution = {}
local filename = ...
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
function verifyArrayOutBounds(index, size)
	if index > size then
		print("Erro: índice fora dos limites do array")
		os.exit(1)
	end
end

--Transforma os indices negativos em positivos e coloca de uma forma que exista a posição 0
--O INDICE PASSADO É 0 MAS ELE ACESSARÁ A POSIÇÃO 1 
function resolveArrayIndex(index, size)
	local newIndex
	if index < 0 then
		--Não confunda, estou fazendo uma soma, mas como index é negativo então na verdade isso vira uma subtração
		--Somo 1 para acessar a posição 1 de lua e não 0
		newIndex = index + size + 1
	else
		newIndex = index + 1
	end
	verifyArrayOutBounds(newIndex, size)
	return newIndex
end

--Função minha para diferenciar os prints e o que eu queria realmente debugar
function debugLine(...)
	print(...)
end

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Regex--------------------------------------------------------------------
--Remove os comenários que estão após o //--FUNÇÃO NÃO ESTÁ FUNCIONANDO COMO O ESPERADO
function removeComments(line)
	if string.find(line, "//") ~= nil then
		local lixo = string.match(line,"[^//]*$")
		print("NOVA LINHA", string.gsub(line, lixo, ""))
		local semLixo = string.gsub(line, lixo, "")
		print(semLixo)
		return semLixo	
	else
		print(line)
		return line
	end
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
function getVariableNameIn_Declaration(lineNumber)
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
	local varValue = tonumber(string.match(progLines[lineNumber], " %d+"))
	return varValue
end

--Pega o nome do vetor que está sendo usado dentro do corpo da função
function getVectorName(str)
	local vectorName = string.match(str, "[^%[]*")
	vectorName = string.gsub(vectorName, "%s*", "") 
	return vectorName
end

--Pega o número do índice presente nos colchetes vetor
function getVectorIndex(str)
	local vectorIndex = tonumber(string.match(str, "%[(%-*%d+)%]"))
	return vectorIndex
end

--Verifica se a variável é um número ou vetor. Se for número o retorna true, se vetor, false.
function isVariableANumber(str)
	local myStr = string.find(str, "%[")
	--Se for nil então não existe o caractere "[", então é é um número comum, caso contrário é um vetor
	if myStr == nil then 
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
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Principais---------------------------------------------------------------

--Abre o arquivo e salva ele localmente na variavel global progLines
function prepareFile()
	-- Pega o nome do arquivo passado como parâmetro (se houver)
	
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

--Salva o arquivo na variavel global progLines. Observe que ele será salvo com os comentários removidos e sem espaços iniciais
function saveFile(file)
	for line in file do
		--local tempStr = removeComments(line)
		local tempStr = removeInitialWhiteSpaces(line)
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

	if functionName == "print" then
		print(args)
	end

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
	executeFunctionBody(bodyBegin, bodyEnd, stackPosition)

	return stackExecution[stackPosition]["ret"]
end

-- Executa o conteúdo presente no corpo da função, observe que esse conteúdo se inicia 1 linha após o "begin" e finaliza 1 linha antes do "end"
function executeFunctionBody(bodyBegin, bodyEnd, stackPosition)
	local lineNumber = bodyBegin + 1
	while  lineNumber < bodyEnd do
		if verifyAction(lineNumber) == "attribuition" then
			resolveAttribuition(lineNumber, stackPosition)
			lineNumber = lineNumber + 1
		elseif verifyAction(lineNumber) == "comparation" then
			--Resolve comparation vai retornar o numero de linhas que já foi executado dentro dele
			lineNumber = lineNumber + resolveComparation(lineNumber, stackPosition)
		elseif verifyAction(lineNumber) == "functionCall" then
			resolveFunctionCall(lineNumber, stackPosition)
			lineNumber = lineNumber + 1
		else
			--Não faz nada, provavelmente leu uma linha em branco do arquivo
			lineNumber = lineNumber + 1
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
function resolveAttribuition(lineNumber, stackPosition)
	print(progLines[lineNumber], "atribuição")
	local myLeftVarName, myLeftVarIndex = resolveLeftSide(lineNumber)
	local myRightValue = resolveRightSide(lineNumber, stackPosition)

	--Se não há index na variável então a variavel é simples, logo precisamos apenas colocar o valor dela dentro da stack
	if myLeftVarIndex == nil then
		putVariableValueInStack(myLeftVarName, stackPosition, myRightValue)
	else
		--Antes de tentar atribuir o valor iremos verificar se é possível acessar o indice do vetor e fazer as alterações para podermos
		--Receber índices iniciados com 0 pq na linguagem do BRUNO os vetores iniciam com o INDICE 0
		myLeftVarIndex = resolveArrayIndex(myLeftVarIndex, stackExecution[stackPosition].vectorVariables[myLeftVarName].size)
		putVectorValueInStack(myLeftVarName, myLeftVarIndex, stackPosition, myRightValue)
	end
end

--Coloca o valor de um vetor, em um indice especifico, dentro da stack
function putVectorValueInStack(vectorName, vectorIndex, stackPosition, value)
	stackExecution[stackPosition].vectorVariables[vectorName].values[vectorIndex] = value
end

--Coloca o valor de uma varíável dentro da stack
function putVariableValueInStack(variableName, stackPosition, value)
	stackExecution[stackPosition].simpleVariables[variableName] = value
end

--Retorna o nome da variável que está presente no lado esquerdo da equação
function resolveLeftSide(lineNumber)
	local myStr = progLines[lineNumber]
	--Lê tudo até o primeiro espaço em branco.
	local leftSide = string.match(myStr, "^(%S+)")
	--Se for vetor retorna o nome do vetor e o índice
	if string.match(leftSide, "%[") == "[" then
		return getVectorName(leftSide), getVectorIndex(leftSide)
	--Se não retorna o valor original que será o nome da variavel simples
	else
		return leftSide
	end
end

--Resolve e retorna o valor do lado direito da equação como número ou o
function resolveRightSide(lineNumber, stackPosition)
	local myStr = progLines[lineNumber]
	local operation = verifyOperation(lineNumber)

	if operation == "singleValue" then
		local rightValue = getRightSideSingleValue(lineNumber)
		--Se for diferente de nil é porque é um número puro então retornamos ele
		if tonumber(rightValue) ~= nil then
        	return tonumber(rightValue)
        --Se não for número então é uma variável, então devemos pegar o valor da variável antes de retornar
		else
			rightValue = getVariableValueFromStack(rightValue, stackPosition)
			return rightValue
		end
	elseif operation == "functionCall" then
		return resolveFunctionCall(myStr)
	elseif operation == "+" or operation == "-" or operation == "/" or operation == "*" then
		print("ENTROU AQUI PELO MENOS")
		return resolveOperation(lineNumber, stackPosition)
	end	
end

--Resolve a operação que estará do lado direito da atribuição
function resolveOperation(lineNumber, stackPosition)
	local lixo, leftValue, lixo2, operation, lixo3, rightValue = string.match(progLines[lineNumber], "(=%s+)([^%s]*)(%s+)(.)(%s+)([^%s]*)")
	--print("LeftValue", leftValue, "RightValue", rightValue)

	--Primeiramente resolvemos o valor da esquerda e da direita Depois verificamos qual foi a operação solicitida e fazemos o calculo
	local solvedRightValue, solvedLeftValue
	--Se ele for um número então ele será usado diretamente se não o valor dele será buscado dentro da stack
	if tonumber(rightValue) ~= nil then
		solvedRightValue = rightValue
	--Se ele for função então devemos resolver ela para pegar o valor
	elseif isFunction(rightValue) then
		solvedRightValue = resolveFunctionCall()
	--Se não for nem função nem valor puro então ele é uma variável e o valor dele será buscado dentro da stack
	else 
		solvedRightValue = getVariableValueFromStack(rightValue, stackPosition)
	end


	if tonumber(leftValue) ~= nil then
		solvedLeftValue = leftValue
	elseif isFunction(leftValue) then
		solvedLeftValue = resolveFunctionCall()
	else 
		solvedLeftValue = getVariableValueFromStack(leftValue, stackPosition)
	end


	if operation == "+" then
		return math.floor(solvedLeftValue + solvedRightValue)
	elseif operation == "-" then
		return math.floor(solvedLeftValue - solvedRightValue)
	elseif operation == "*" then
		return math.floor(solvedLeftValue * solvedRightValue)
	elseif operation == "/" then
		return math.floor(solvedLeftValue / solvedRightValue)
	end
end

--Verifica se a string passada é uma função
function isFunction(str)
	if string.match(str, "%(") == "(" then
		return true
	else
		return false
	end
end

-- function resolveSum(leftValue, rightValue, lineNumber, stackPosition)
-- 	local solvedRightValue, solvedLeftValue
-- 	--Se ele for um número então ele será usado diretamente se não o valor dele será buscado dentro da stack
-- 	if tonumber(rightValue) ~= nil then
-- 		solvedRightValue = rightValue
-- 	--Se ele for função então devemos resolver ela para pegar o valor
-- 	elseif isFunction(rightValue) then
-- 		solvedRightValue = resolveFunctionCall()
-- 	--Se não for nem função nem valor puro então ele é uma variável e o valor dele será buscado dentro da stack
-- 	else 
-- 		solvedRightValue = getVariableValueFromStack(rightValue, stackPosition)
-- 	end

-- 	if tonumber(leftValue) ~= nil then
-- 		solvedLeftValue = leftValue
-- 	elseif isFunction(leftValue) then
-- 		solvedLeftValue = resolveFunctionCall()
-- 	else 
-- 		solvedLeftValue = getVariableValueFromStack(leftValue, stackPosition)
-- 	end

-- 	return math.floor(solvedLeftValue + solvedRightValue)
-- end




function getVariableValueFromStack(varName, stackPosition)
	print("String Recebida "..varName)
	--Verificamos se a variável é um numero ou vetor
	if isVariableANumber(varName) then
		return stackExecution[stackPosition].simpleVariables[varName]
	else
		local myVectorVar = getVectorName(varName)
		local myVectorIndex = getVectorIndex(varName)
		--Faço as transformações necessárias para gerar um indice válido
		local newIndex = resolveArrayIndex(myVectorIndex, stackExecution[stackPosition].vectorVariables[myVectorVar].size)
		return stackExecution[stackPosition].vectorVariables[myVectorVar].values[newIndex]
	end
end


--Retorna o único valor presente no lado direito seja ele um número ou uma variável
function getRightSideSingleValue(lineNumber)
	local myStr = progLines[lineNumber]
	--Lê tudo até o primeiro espaço em branco
	local rightValue = string.match(myStr, "=(.*)")
	--Removo o sinal de atribuição
	rightValue = string.gsub(rightValue, "=", "") 
	--Removo os espaços em branco
	rightValue = string.gsub(rightValue, "%s", "") 
	--print("lado direito da equação: ", rightValue)
	return rightValue
end


function verifyOperation(lineNumber)
	local myStr = progLines[lineNumber]

	if string.match(myStr, " %+ ") == " + " then
		return "+"
	elseif string.match(myStr, " %- ") == " - " then
		return "-"
	elseif string.match(myStr, " %/ ") == " / " then
		return "/"
	elseif string.match(myStr, " %* ") == " * " then
		return "*"		
	elseif string.match(myStr, "%(") == "(" then
		return "functionCall"
	else
		return "singleValue"
	end			
end



--Resolve comparação (IF-ELSE)
function resolveComparation(lineNumber, stackPosition)
	local ifWord, leftValue, lixo, comparationSimbol, lixo2, rightValue  = string.match(progLines[lineNumber], "(if%s+)([^%s]*)(%s+)([^%s]*)(%s+)([^%s]*)")
	local solvedLeftValue, solvedRightValue
	--print(string.match(progLines[lineNumber], "(if%s+)([^%s]*)(%s+)([^%s]*)(%s+)([^%s]*)"))

	--Resolvemos o lado esquerdo da comparação
	if tonumber(leftValue) ~= nil then
		solvedLeftValue = leftValue
	else
		solvedLeftValue = getVariableValueFromStack(leftValue, stackPosition)
	end

	--Resolvemos o lado direito da comparação
	if tonumber(rightValue) ~= nil then
		solvedRightValue = rightValue
	else
		solvedRightValue = getVariableValueFromStack(rightValue, stackPosition)
	end

	--Se for verdadeiro executa o comando dentro do corpo do if
	if comparationSimbol == "==" and solvedLeftValue == solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == "==" and not (solvedLeftValue == solvedRightValue) then 
		--verifica se tem else, se sim executa o comando dentro do corpo do else
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end
	--------------------------------------------------------------------------
	elseif comparationSimbol == "!=" and solvedLeftValue ~= solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == "!=" and not (solvedLeftValue ~= solvedRightValue) then 
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end			
	--------------------------------------------------------------------------
	elseif comparationSimbol == "<" and solvedLeftValue < solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == "<" and not (solvedLeftValue < solvedRightValue) then 
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end		
	--------------------------------------------------------------------------
	elseif comparationSimbol == "<=" and solvedLeftValue <= solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == "<=" and not (solvedLeftValue <= solvedRightValue) then 
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end	
	---------------------------------------------------------------------------
	elseif comparationSimbol == ">" and solvedLeftValue > solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == ">" and not (solvedLeftValue > solvedRightValue) then 
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end		
	elseif comparationSimbol == ">=" and solvedLeftValue >= solvedRightValue then
		resolveAttribuition(lineNumber+1, stackPosition)
	elseif comparationSimbol == ">=" and not (solvedLeftValue >= solvedRightValue) then 
		if existsElse(lineNumber+2) then
			resolveAttribuition(lineNumber+3, stackPosition)
		end	
	end

	--Vou retornar o Número de linhas do corpo dessa estrutura IF-ELSE
	if existsElse(lineNumber+2) then
		return 5
	else
		return 3
	end
end

--Verifica se existe else na linha
function existsElse(lineNumber)
	if string.match(progLines[lineNumber], "else") == "else" then
		return true
	else
		return false
	end
end

--Resolve chamada de função
function resolveFunctionCall(str)
	--Pega o nome da função
	local funcName = string.match(str, "%s+[^%(]*")
	return 0
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



--Retorna uma lista com as variáveis(simples e vetores) declaradas e inicializadas com 0's
function getVariablesList(lineNumber)
	local simpleVariables = {}
	local vectorVariables = {}
	--Se não há "begin" quer dizer que ainda estamos em uma linha que contém as declarações das variáveis
	while (not isThere_BEGIN_InThisLine(lineNumber)) do

		if isVariableANumber(progLines[lineNumber]) then
			local nameField = getVariableNameIn_Declaration(lineNumber)
			--Como na declaração da variável não há valor iremos iniciar com 0--Isso está sendo pedido no trabalho
			local value = 0
			--Os valores serão armazenados em um campo com o nome da variável
			simpleVariables[nameField] = value

		else
			local nameField = getVariableNameIn_Declaration(lineNumber)
			local vectorSize = getVectorIndex(progLines[lineNumber])
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
end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


------------------------Execução do Programa principal-------------------------------------------------------------------------
preProcessing()


executeFunction("main")

print("stackExecutionSize: ", #stackExecution)


pretty.dump(functionsTable)
pretty.dump(stackExecution)
--pretty.dump(functionsTable)
--pretty.dump(progLines)

-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
