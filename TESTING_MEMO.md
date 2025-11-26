# 📋 Testing Memo & Seed Data Recap

This document outlines the seed data available for testing the application.

## 🔑 Credentials

| User | Login | Password | Role |
| :--- | :--- | :--- | :--- |
| **Alice** | `alice@example.com` | `password` | **Main Tester** (Has trips in all states) |
| **Bob** | `bob@example.com` | `password` | Collaborator (Creator of Trip D) |
| **Charlie** | `charlie@example.com` | `password` | Collaborator (Creator of Trip E) |

## 🧪 Test Scenarios (Log in as Alice)

Once logged in as **Alice**, you can test the following scenarios:

### 1. ✈️ Paris Getaway
*   **Status:** `Just Created`
*   **Action:** Test generating recommendations.

### 2. 🍣 Tokyo Adventure
*   **Status:** `Recommendations Ready`
*   **Action:** Test voting/selecting activities.

### 3. 🗽 NYC Business Trip
*   **Status:** `Itinerary Ready`
*   **Action:** Test viewing the final day-by-day plan.

### 4. 💂 London Calling
*   **Status:** `Joined`
*   **Context:** Created by Bob.
*   **Action:** Test participant view (voting, etc.).

### 5. 🍺 Berlin Tech Conf
*   **Status:** `Pending Invite`
*   **Context:** Created by Charlie.
*   **Action:** Test accepting the invitation.

## 🔄 Resetting Data

To reset the database to this state and see this info in your terminal:

```bash
rails db:seed
```
