// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.24;

/// @title AgentRegistry (DARS)
/// @notice Users assign agents per domain. A designated guardian can ONLY revoke.
///         The guardian can never assign or act as the user.
contract AgentRegistry {
    struct AgentInfo {
        address agent;
        uint64  expiresAt;   // 0 = no expiry
        bool    active;
    }

    // user => domain => AgentInfo
    mapping(address => mapping(bytes32 => AgentInfo)) private _auth;

    // user => domain => guardian (revocation-only authority)
    mapping(address => mapping(bytes32 => address)) private _guardian;

    event AgentAssigned(address indexed user, address indexed agent, bytes32 indexed domain, uint64 expiresAt);
    event AgentRevoked(address indexed user, address indexed agent, bytes32 indexed domain, address byGuardian);
    event GuardianSet(address indexed user, bytes32 indexed domain, address guardian);

    /// ---------- USER FUNCTIONS ----------

    /// @notice Set or change the guardian for a domain (who can revoke on your behalf).
    function setGuardian(bytes32 domain, address guardian_) external {
        require(guardian_ != address(0), "guardian=0");
        _guardian[msg.sender][domain] = guardian_;
        emit GuardianSet(msg.sender, domain, guardian_);
    }

    /// @notice Assign/replace your agent for a domain.
    function assignAgent(bytes32 domain, address agent, uint64 expiresAt) external {
        require(agent != address(0), "agent=0");
        // Optional: limit far-future expiries
        if (expiresAt != 0) require(expiresAt > block.timestamp, "expiry in past");

        _auth[msg.sender][domain] = AgentInfo({
            agent: agent,
            expiresAt: expiresAt,
            active: true
        });

        emit AgentAssigned(msg.sender, agent, domain, expiresAt);
    }

    /// ---------- GUARDIAN FUNCTION (REVOCATION-ONLY) ----------

    /// @notice Guardian revokes the agent for `user` in `domain`. Cannot assign.
    function revokeAgent(address user, bytes32 domain) external {
        require(msg.sender == _guardian[user][domain], "not guardian");
        AgentInfo storage ai = _auth[user][domain];
        require(ai.active, "no active agent");

        address prev = ai.agent;
        ai.active = false;
        ai.agent = address(0);
        ai.expiresAt = 0;

        emit AgentRevoked(user, prev, domain, msg.sender);
    }

    /// ---------- READS ----------

    function guardianOf(address user, bytes32 domain) external view returns (address) {
        return _guardian[user][domain];
    }

    function agentOf(address user, bytes32 domain) external view returns (AgentInfo memory) {
        return _auth[user][domain];
    }

    function isAuthorized(address user, address agent, bytes32 domain) external view returns (bool) {
        AgentInfo memory ai = _auth[user][domain];
        if (!ai.active || ai.agent != agent) return false;
        if (ai.expiresAt != 0 && block.timestamp >= ai.expiresAt) return false;
        return true;
    }
}
