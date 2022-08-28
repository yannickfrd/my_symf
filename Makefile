.PHONY: install cc help server proxy watch npm-i test-unit test-functional test-end2end test-all test-install create-db-test delete-db-test recreate-db-test update-schema-db-test analyse analyse-fix stan cs

#include .env
#include .env.test

#.SILENT:
.DEFAULT_GOAL = help
PORT?=8000
HOST=127.0.0.1

COM_COLOR 	= \033[0;34m
OBJ_COLOR 	= \033[0;36m
OK_COLOR 	= \033[0;32m
ERROR_COLOR = \033[0;31m
WARN_COLOR 	= \033[0;33m
NO_COLOR 	= \033[m

help: ## Liste des aides
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-10s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

vendor: composer.json
	@echo -e "$(OBJ_COLOR)Installation des dependances :$(NO_COLOR)"
	composer install

composer.lock: composer.json
	composer update

npm-i: node_modules  ## Installation des dépendances via npm
	@echo -e "$(OBJ_COLOR)Lancement de \"npm install\" :$(NO_COLOR)"
	npm install

npm-watch: npm-i ## Lancement du "watch" via npm
	@echo -e "$(OBJ_COLOR)Lancement de \"npm run watch\" :$(NO_COLOR)"
	npm run watch

create-db-dev: ## Création de la base de donnée
	@echo -e "$(OBJ_COLOR)Creation de la base de donnee de test :$(NO_COLOR)"
	php bin/console doctrine:database:create --if-not-exists

update-schema-db-dev: ## Mise à jour de la base de donnée
	@echo -e "$(OBJ_COLOR)Mise a jour de la base de donnee de test :$(NO_COLOR)"
	php bin/console doctrine:schema:update --force --no-interaction

install: vendor composer.lock npm-i create-db-dev update-schema-db-dev ## installation du projet

cc: ## Cache clear
	@echo -e "$(OBJ_COLOR)Suppression du cache :$(NO_COLOR)"
	php bin/console cache:clear

test-unit: ## Lancement des tests unitaires
	@echo -e "$(OBJ_COLOR)Lancement des tests unitaires :$(NO_COLOR)"
	php ./vendor/bin/phpunit --group 'unit'

test-functional: ## Lancement des tests fonctionnels
	@echo -e "$(OBJ_COLOR)Lancement des tests fonctionnels :$(NO_COLOR)"
	php ./vendor/bin/phpunit --group 'functional'

test-end2end: ## Lancement des tests end to end
	@echo -e "$(OBJ_COLOR)Lancement des tests end to end :$(NO_COLOR)"
	php ./vendor/bin/phpunit --group 'end2end'

tests: test-unit test-functional test-end2end ## Lancement des tests unitaires, fonctionnels, puis end to end

test-install: vendor/bin/phpunit ## Installation et lancement des tests
	php ./vendor/bin/phpunit

update-schema-db-test: ## Mise à jour de la base de donnée de test
	@echo -e "$(OBJ_COLOR)Mise a jour de la base de donnee de test :$(NO_COLOR)"
	php bin/console doctrine:schema:update --env=test --force

create-db-test: ## Création de la base de donnée de test
	@echo -e "$(OBJ_COLOR)Creation de la base de donnee de test :$(NO_COLOR)"
	php bin/console doctrine:database:create --env=test

delete-db-test: ## Suppression de la base de donnée de test
	@echo -e "$(OBJ_COLOR)Suppression de la base de donnee de test :$(NO_COLOR)"
	php bin/console doctrine:database:drop --env=test --force

reload-db-test: delete-db-test create-db-test update-schema-db-test

load-db-test: create-db-test update-schema-db-test
#	@echo -e "$(OBJ_COLOR)Chargement des données de test ...$(NO_COLOR)"
#	php bin/console hautelook:fixtures:load --env=test --no-interaction

messenger-consume:
	symfony console messenger:consume async -vv

stan:
	@echo -e "$(OBJ_COLOR)Analise du code php :$(NO_COLOR)"
	vendor\bin\phpstan analyse

cs:
	@echo -e "$(OBJ_COLOR)Analise du code avec cs-fixer :$(NO_COLOR)"
	vendor\bin\php-cs-fixer src --dry-run --verbose

analyse: stan cs

analyse-ci:
	@echo -e "$(OBJ_COLOR)Analise du code php :$(NO_COLOR)"
	./vendor/bin/phpstan analyse
	@echo -e "$(OBJ_COLOR)Analise du code avec cs-fixer :$(NO_COLOR)"
	./vendor/bin/php-cs-fixer fix src --dry-run --verbose

analyse-fix: analyse
	@echo -e "$(OBJ_COLOR)Analyse et correction avec php-cs-fixer :$(NO_COLOR)"
	vendor\bin\php-cs-fixer fix --verbose
