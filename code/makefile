# Nombre del archivo de simulación
TOP_MODULE = tb
SIM_TOOL = iverilog
WAVE_FILE = uart_full_duplex_system_tb.vcd

# Regla por defecto
all: compile simulate view

# 1. Compilar los archivos Verilog
compile:
	$(SIM_TOOL) -o simulation $(TOP_MODULE).v UartDUT.v

# 2. Simular y generar archivo .vcd
simulate:
	vvp simulation

# 3. Abrir GTKWave con el archivo de ondas
view:
	gtkwave $(WAVE_FILE)

# 4. Limpiar los archivos generados
clean:
	rm -f simulation $(WAVE_FILE)