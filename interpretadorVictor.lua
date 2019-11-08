-------------------------------Variaveis globais--------------------------------------------------------------------------------
progLines = {}
functionsTable = {}
stackExecution = {}
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


-------------------------------Declaração das funções--------------------------------------------------------------------------
--Abre o arquivo e salva ele localmente na variavel global progLines
function prepareFile()
	-- Pega o nome do arquivo passado como parâmetro (se houver)
	local filename = "teste1.bpl"
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
	end
end

--Procura pelas funções existentes no programa e salva na tabela 
function identifyFunctions()
	for i = 1, #progLines do 
  		if string.find(progLines[i], "function") ~= nil then			
			functionsTable[#functionsTable + 1] = { ["name"] = getFunctionName(progLines[i]), ["pos"] = i+1}
		end
	end
end

function removeComments(line)
	return string.match(line, "[^//]*")
end

function getFunctionName(line)
	--Pego tudo depois do espaço em branco após a palavra "function" até o primeiro caracter "("
	local functionName = string.match(line, " [^%(]*")
	--Removo o espaço em branco que restou no inicio da string 
	functionName = string.sub(functionName, 2)
	return functionName
end



--Imprime o conteúdo da tabela de funções
function printfunctionsTable()
	for i = 1, #functionsTable do 
		print(functionsTable[i].name, functionsTable[i].pos)
	end
end

--Procura onde a função se inicia 
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

	if isThereVariablesInThisFunction(funcPosition+1) then
		stackExecution[stackPosition].variables = getVariablesNameAndValues(funcPosition+1)
	end
end

--Verifica se a função possui variáveis.
function isThereVariablesInThisFunction(lineNumber)
	--Se existir a palavra "begin" quer dizer que não há variáveis locais.
	if isThereBEGINInThisLine(lineNumber) then
		return true
	else
		return false
	end
end

function isThere_BEGIN_InThisLine(lineNumber)
	local str = string.match(progLines[lineNumber], "begin")
	if (str == "begin") then 
		return true
	else
		return false
	end	
end

--Retorna uma lista com o nome das variaveis simples e dos vetores (nesse caso salva o tamanho do vetor)
function getVariablesList(lineNumber)
	local variablesAndValues = {}
	local i = lineNumber
	--Se não há "begin" quer dizer que a contém as declarações das variáveis
	while (not isThere_BEGIN_InThisLine(i)) do

		if (isVariableANumber(i)) then
			local nameField = getVariableName(i)
			print(nameField)
		else
			local nameField = getVariableName(i)
			local vectorSize = getVectorSize(i)
			print(nameField, vectorSize)
		end

		i = i + 1
	end
end

--Pega o nome da variável seja ela uma variável simples ou um vetor
function getVariableName(lineNumber)
	--Pego tudo depois do espaço em branco após a palavra "var" até o primeiro caracter "[" (caso ele exista).
	local varName = string.match(progLines[lineNumber], "var [^%[]*")
	--print("linha completa: "..varName)
	--Removo o "var " que restou no inicio da string 
	varName = string.sub(varName, 5)
	return varName
end

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

-- function isThereParametersInThisFunction(lineNumber)
-- 	if
-- 	return true
-- end


--Faz o pré processmento
--Salva o arquivo lido na tabela "progLines" e procura pelas funções existentes no programa e as salva em "functionsTable"
function preProcessing()
	prepareFile()
	identifyFunctions()
	printfunctionsTable()
end
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------


------------------------Execução do Programa principal-------------------------------------------------------------------------
preProcessing()
getVariablesList(2)

--executeFunction("main")


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
