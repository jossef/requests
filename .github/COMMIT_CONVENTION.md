# Git Commit Convention

We are using the following convention for writing git-commit messages.
It is based on the one from AngularJS project([doc][angularjs-doc],
[commits][angularjs-git]).

[angularjs-doc]: https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#
[angularjs-git]: https://github.com/angular/angular.js/commits/master

## Format of the commit message

```
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

A commit message consists of a header, a body and a footer, separated by a blank line.

### Revert
If the commit reverts a previous commit, its header should begin with `revert: `, 
followed by the header of the reverted commit. In the body it should say: `This reverts commit <hash>.`, 
where the hash is the SHA of the commit being reverted.

### Message header    
The message header is a single line that contains succinct description of 
the change containing a type, an optional scope and a subject.

Allowed `<type>`: This describes the kind of change that this commit is providing.
- feat (feature)
- fix (bug fix)
- docs (documentation)
- style (formatting, missing semi colons, …)
- refactor
- test (when adding missing tests)
- chore (maintain)

Allowed `<scope>`: Scope can be anything specifying place of the commit change. For example $location, deps, etc...

You can use * if there isn't a more fitting scope.

`<subject>` text: This is a very short description of the change.
- use imperative, present tense: "change" not "changed" nor "changes"
- don't capitalize first letter
- no dot (.) at the end

### Message body
- just as in `<subject>` use imperative, present tense: "change" not "changed" nor "changes"
- includes motivation for the change and contrasts with previous behavior

### Message footer
- Breaking changes: All breaking changes have to be mentioned in footer 
  with the description of the change, justification and migration notes
- Referencing issues: Closed bugs should be listed on a separate line 
  in the footer prefixed with "Closes" keyword like this:

    Closes #123, #456
