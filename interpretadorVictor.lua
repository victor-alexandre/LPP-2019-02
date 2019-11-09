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
		print(functionsTable[i].name, functionsTable[i].pos)
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

--Pega o nome da variável seja ela uma variável simples ou um vetor
function getVariableName(lineNumber)
	--Pego tudo após a palavra "var" + n characteres em branco até o primeiro caracter "[" (caso ele exista).
	local str = string.match(progLines[lineNumber], "var%s+[^%[]*")

	--debugLine(string.gsub(varName, "%s+", "."))
	--Removo o "var" + caracteres em branco que restou no inicio da string
	--local varName = string.gsub(str, "var%s+", "") 
	local varName = removeReservedWordAndInitialWhiteSpaces("var", str)
	return varName
end

--Pega o valor da variável
function getVariableValue(lineNumber)
	local varValue = string.match(progLines[lineNumber], " %d+")
	return varValue
end

--Pega o tamanho do vetor que foi declarado
function getVectorSize(lineNumber)
	local vectorSize = string.match(progLines[lineNumber], "%[(%d+)%]")
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
	local functionName = removeReservedWordAndInitialWhiteSpaces("function", str)
	return functionName
end


function removeReservedWordAndInitialWhiteSpaces(reservedWord, str)
	local regexParameter = reservedWord.."%s+"
	--debugLine(".."..string.gsub(str, regexParameter, "").."..")
	return string.gsub(str, regexParameter, "") 
end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------Declaração das funções Principais---------------------------------------------------------------

--Abre o arquivo e salva ele localmente na variavel global progLines
function prepareFile()
	-- Pega o nome do arquivo passado como parâmetro (se houver)
	local filename = "./testes/teste5.bpl"
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
		progLines[#progLines + 1] = removeComments(line)
		--progLines[#progLines + 1] = line
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

--Procura a linha onde a função é declarada
function searchFunctionPositionInFunctionsTable(functionName)
	for i = 1, #functionsTable do 
		if (functionsTable[i].name == functionName) then
			return functionsTable[i].pos 
		end
	end
end

--Executa a função passada como parametro
function executeFunction(functionName)
	local stackPosition = #stackExecution + 1
	local funcPosition = searchFunctionPositionInFunctionsTable(functionName)

	-- if isThereParametersInThisFunction(funcPosition) then
	-- end
	declareVariables(funcPosition,stackPosition)

end


--Salva as variáveis (na estrutura da função) dentro da stackExecution
function declareVariables(funcPosition, stackPosition)
	--Se existir variáveis na função elas serão salvas na estrutura presente na stackExecution
	if (isThereVariablesInThisFunction(funcPosition)) then
		local simpleVariablesValues, vectorVariablesValues = getVariablesList(funcPosition)
		stackExecution[stackPosition] = {simpleVariables = simpleVariablesValues, vectorVariables = vectorVariablesValues}
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
	local str = string.match(progLines[lineNumber], "begin")
	if (str == "begin") then 
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

		if (isVariableANumber(lineNumber)) then
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


--Faz o pré processmento
--Salva o arquivo lido na tabela "progLines" e procura pelas funções existentes no programa e as salva em "functionsTable"
function preProcessing()
	prepareFile()
	identifyFunctions()
	printfunctionsTable()--REMOVER DEPOIS ESSA LINHA******************************************
end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


------------------------Execução do Programa principal-------------------------------------------------------------------------
preProcessing()


executeFunction("main")

print("stackExecutionSize: ", #stackExecution)
print("vetor na posição 1: " , stackExecution[1].vectorVariables["a"].values[1])
printVector(stackExecution[1].vectorVariables["a"].values)



require 'pl.pretty'.dump(stackExecution)
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
