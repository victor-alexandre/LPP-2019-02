-------------------------------Variaveis globais----------------------------
linhas = {}
functionsTable = {}
----------------------------------------------------------------------------


-------------------------------Declaração das funções----------------------------

--Abre o arquivo e salva ele localmente na variavel global linhas
function prepareFile()
	--
	-- Pega o nome do arquivo passado como parâmetro (se houver)
	--
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
	--Salva o arquivo na variavel global linhas
	saveFile(file:lines())

	file:close()
end	

--Salva o arquivo na variavel global linhas
function saveFile(file)
	for line in file do
		linhas[#linhas + 1] = line
	end
end

--Procura pelas funções existentes no programa e salva na tabela 
function identifyFunctions()
	for i = 1, #linhas do 
  		if string.find(linhas[i], "function") ~= nil then
			--Pego tudo depois do espaço em branco após a palavra "function" até o primeiro caracter "("
			local functionName = string.match(linhas[i], " [^%(]*")
			--Removo o espaço em branco
			functionName = string.sub(functionName, 2)
			functionsTable[#functionsTable + 1] = { ["name"] = functionName, ["pos"] = i}
		end
	end
end

--Imprime o conteúdo da tabela de funções
function printfunctionsTable()
	for i = 1, #functionsTable do 
		print(functionsTable[i].name, functionsTable[i].pos)
	end
end

--Faz o pré processmento
--Salva o arquivo lido na tabela "linhas" e procura pelas funções existentes no programa e as salva em "functionsTable"
function preProcessing()
	prepareFile()
	identifyFunctions()
	printfunctionsTable()
end




-------------------------------Programa principal----------------------------
preProcessing()




----------------------------------------------------------------------------