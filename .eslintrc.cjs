/* eslint-env node */
/** @type {import('eslint').Linter.Config} */
module.exports = {
  root: true,
  env: {
    browser: true,
    node: true,
    es2022: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2022,
    sourceType: 'module',
    project: ['./tsconfig.json', './apps/*/tsconfig.json', './packages/*/tsconfig.json'],
    tsconfigRootDir: __dirname,
  },
  plugins: ['@typescript-eslint', 'import'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/recommended-requiring-type-checking',
    'plugin:import/recommended',
    'plugin:import/typescript',
    'prettier', // must be last — disables stylistic rules conflicting with Prettier
  ],
  settings: {
    'import/resolver': {
      typescript: { alwaysTryTypes: true },
      node: true,
    },
  },
  rules: {
    // ---- Type safety ----
    '@typescript-eslint/no-explicit-any': 'error',
    '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_', varsIgnorePattern: '^_' }],
    '@typescript-eslint/explicit-function-return-type': 'off',
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-floating-promises': 'error',
    '@typescript-eslint/no-misused-promises': 'error',
    '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],

    // ---- Style / safety ----
    'no-console': ['warn', { allow: ['warn', 'error'] }],
    'no-debugger': 'error',
    'prefer-const': 'error',
    'eqeqeq': ['error', 'always', { null: 'ignore' }],

    // ---- Imports ----
    'import/order': [
      'error',
      {
        groups: ['builtin', 'external', 'internal', ['parent', 'sibling', 'index']],
        'newlines-between': 'always',
        alphabetize: { order: 'asc', caseInsensitive: true },
      },
    ],
    'import/no-default-export': 'error', // override per-file for React pages
    'import/no-cycle': 'error',

    // ---- Architectural boundaries (lint-enforced) ----
    // See AGENTS.md Section 5. Don't suppress these without an ADR.
    'no-restricted-imports': [
      'error',
      {
        patterns: [
          {
            group: ['**/apps/*/src/**', '!**/apps/<self>/**'],
            message: 'apps/* cannot import from each other. Extract shared code to packages/shared.',
          },
          {
            group: ['**/features/*/**', '!**/features/<self>/**'],
            message: 'features/* slices cannot import from each other. Refactor or open an ADR.',
          },
          {
            group: ['**/apps/**', '**/features/**'],
            message: 'packages/shared cannot import from apps/* or features/*. Inversion-of-control violation.',
            // This rule applies when imported FROM packages/shared - see override below.
          },
        ],
      },
    ],
  },
  overrides: [
    {
      files: ['**/*.test.ts', '**/*.test.tsx', '**/*.spec.ts', '**/tests/**/*.ts'],
      rules: {
        '@typescript-eslint/no-explicit-any': 'off',
        'no-console': 'off',
      },
    },
    {
      // React pages / Next.js routes commonly require default export
      files: ['**/pages/**/*.tsx', '**/app/**/*.tsx', 'vite.config.ts', 'vitest.config.ts', '**/eslint.config.*'],
      rules: {
        'import/no-default-export': 'off',
      },
    },
    {
      files: ['*.cjs', '*.js'],
      parser: 'espree',
      rules: {
        '@typescript-eslint/no-var-requires': 'off',
      },
    },
  ],
  ignorePatterns: [
    'node_modules/',
    'dist/',
    'build/',
    'coverage/',
    '.turbo/',
    '05_archive/',
    '03_history/',
  ],
};
