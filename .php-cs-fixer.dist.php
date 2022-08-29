<?php
declare(strict_types=1);

$finder = (new PhpCsFixer\Finder())
    ->in(__DIR__)
    ->exclude('var')
    ->exclude('config')
    ->exclude('node_modules')
    ->exclude('public')
    ->exclude('vendor')
    ->notPath('bin/console')
;

return (new PhpCsFixer\Config())
    ->setRiskyAllowed(true)
    ->setRules([
        '@PhpCsFixer' => true,
        '@PhpCsFixer:risky' => true,
        '@PSR12' => true,
        '@Symfony' => true,
        'array_syntax' => ['syntax' => 'short'],
        'no_unused_imports' => true,
    ])
//    ->setLineEnding(PHP_EOL)
    ->setFinder($finder)
    ->setCacheFile(__DIR__.'/var/.php_cs.cache')
    ;
