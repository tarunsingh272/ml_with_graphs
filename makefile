PYTHON_VERSION := "3.12.1" 
# ls ~/.pyenv/versions/ ## List all the python versions available to pyenv
# pyenv versions ## List all the python versions installed on the system
# pyenv install --list ## List all the python versions available to install
# pyenv uninstall <version> ## Uninstall a specific python version
# pyenv which python
# python -V ## Check the current python version
# pyenv shell system ## Switch to system python
# pyenv virtualenvs # Show available virtualenvs
# pyenv virtualenv-delete -f test ## Delete a virtualenv

.PHONY: setup install_deps activate clean dev_check

setup:
	@bash -c ' \
		read -p "Enter virtual environment name: " vname; \
		read -p "Enter project name: " pname; \
		read -p "Enter project description: " pdesc; \
		echo "Setting up Python environment..."; \
		if ! command -v pyenv >/dev/null 2>&1; then \
			echo "Error: pyenv is not installed. Install it first."; exit 1; \
		fi; \
		if ! command -v poetry >/dev/null 2>&1; then \
			echo "Error: poetry is not installed. Install it first."; exit 1; \
		fi; \
		echo "Using Python version: $(PYTHON_VERSION)"; \
		echo "Creating virtual environment: $$vname"; \
		pyenv install -s $(PYTHON_VERSION); \
		pyenv virtualenv $(PYTHON_VERSION) $$vname; \
		pyenv local $$vname; \
		echo "Python virtual environment $$vname created and activated."; \
		echo "Initializing Poetry project: $$pname"; \
		poetry init --no-interaction \
			--name="$$pname" \
			--description="$$pdesc" \
			--author="singh.tarun.27.pisces@gmail.com" \
			--license="MIT"; \
		echo "Setting Python version in pyproject.toml..."; \
		sed -i.bak "s/\[tool.poetry.dependencies\]/\[tool.poetry.dependencies\]\npython = \"^$(PYTHON_VERSION)\"/" pyproject.toml; \
		rm -f pyproject.toml.bak; \
		echo "Poetry project initialized successfully."; \
	'

install_deps:
	@echo "Adding required dependencies: numpy, pandas, requests..."
	@poetry add pandas requests
	@echo "Adding development dependencies: ruff, pytest, black..."
	@poetry add --dev ruff pytest black
	@echo "Installing all dependencies..."
	@poetry install --no-root

activate:
	@echo "Activating virtual environment..."
	@pyenv activate $$(pyenv local)

clean:
	@echo "Removing virtual environment..."
	@pyenv virtualenv-delete -f $$(pyenv local)
	@rm -f .python-version
	@rm -rf poetry.lock pyproject.toml
	@echo "Environment cleaned."

dev_check:
	@echo "Running Ruff for linting and formatting checks..."
	@echo "[1/3] Running linting checks..."
	@poetry run ruff check --select E,W,F,B --ignore E501 .
	@echo "[2/3] Running formatting checks..."
	@poetry run ruff format --check .
	@echo "[3/3] Applying auto-fixes..."
	@poetry run ruff format .
	@echo "Linting and formatting check completed."
