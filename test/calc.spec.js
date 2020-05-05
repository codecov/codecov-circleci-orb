"use strict";
exports.__esModule = true;
var calc_1 = require("../src/calculator/calc");
var chai_1 = require("chai");
describe('Calculator', function () {
    it('should add two numbers together', function () {
        var calc = new calc_1["default"]();
        chai_1.expect(calc.add(2, 3)).to.equal(5);
    });
});
//# sourceMappingURL=calc.spec.js.map