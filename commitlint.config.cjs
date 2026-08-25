/**
 * commitlint — enforces Conventional Commits.
 *
 * Install with `pnpm add -D @commitlint/{cli,config-conventional}` and wire
 * into Husky's `commit-msg` hook (see .husky/commit-msg).
 */
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      [
        'feat',     // new feature
        'fix',      // bug fix
        'docs',     // documentation only
        'style',    // formatting, no logic change
        'refactor', // code change that neither fixes a bug nor adds a feature
        'perf',     // performance improvement
        'test',     // adding / updating tests
        'build',    // build system / external deps
        'ci',       // CI configuration
        'chore',    // tooling, deps, no production change
        'revert',   // reverting a prior commit
      ],
    ],
    'scope-empty': [1, 'never'],         // warn if scope missing
    'subject-case': [2, 'never', ['upper-case', 'pascal-case', 'start-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 72],
    'body-max-line-length': [1, 'always', 100],
    'footer-leading-blank': [2, 'always'],
  },
};
