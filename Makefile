.PHONY: all build build-docker clean setup check-go

# Директории
LISTS_DIR := lists
OUTPUT_DIR := output
DLC_DIR := domain-list-community

# Выходной файл
OUTPUT_FILE := $(OUTPUT_DIR)/custom.dat

# Проверка наличия Go
HAS_GO := $(shell command -v go 2> /dev/null)
HAS_DOCKER := $(shell command -v docker 2> /dev/null)

all: build

# Проверка Go
check-go:
ifndef HAS_GO
	@echo "Error: Go is not installed!"
	@echo "Please install Go from https://golang.org/dl/"
	@echo "Or use 'make build-docker' if you have Docker installed."
	@exit 1
endif

# Настройка окружения
setup: check-go
	@echo "Setting up domain-list-community..."
	@cd $(DLC_DIR) && go mod download
	@echo "Setup complete!"

# Сборка DAT файла
build: setup
	@echo "Building custom.dat with all lists..."
	@mkdir -p $(OUTPUT_DIR)
	@cd $(DLC_DIR) && go run main.go \
		-datapath=../$(LISTS_DIR) \
		-outputdir=../$(OUTPUT_DIR) \
		-outputname=custom.dat
	@echo "Successfully built $(OUTPUT_FILE)"
	@echo "Available categories:"
	@ls -1 $(LISTS_DIR) | sed 's/^/  - geosite:/'

# Сборка через Docker
build-docker:
ifndef HAS_DOCKER
	@echo "Error: Docker is not installed!"
	@echo "Please install Docker or use 'make build' with Go installed."
	@exit 1
endif
	@./build-docker.sh

# Очистка
clean:
	@echo "Cleaning output directory..."
	@rm -rf $(OUTPUT_DIR)/*.dat
	@echo "Clean complete!"

